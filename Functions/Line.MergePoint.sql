function LINE__MERGE_POINT(p_line sdo_geometry, p_point sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  type lrs_vertex_pair is record (x number, y number, distance number);
  type lrs_vertex_hashtable is table of lrs_vertex_pair index by pls_integer;
  t_vertices     lrs_vertex_hashtable;
  t_lrs_line     sdo_geometry;
  t_point_dist   number;
  t_line_dist    number;
  t_result       sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  
  -- Validate Point
  if p_point.sdo_gtype not in ('2001') then
    raise_application_error(-20001, 'The Point must have an SDO_GTYPE of 2001');
  end if;
  
  -- Set Variables (must be after Validation)
  t_lrs_line := sdo_lrs.convert_to_lrs_geom(p_line);
  t_point_dist := sdo_lrs.project_pt(t_lrs_line, p_point).sdo_ordinates(3);
  t_line_dist := t_lrs_line.sdo_ordinates(t_lrs_line.sdo_ordinates.count()); -- get the last ordinate, which is distance for final point
  
  -- Populate the Hashtable
  for i in 1..(t_lrs_line.sdo_ordinates.count() / 3) loop   
    t_vertices(i).x := t_lrs_line.sdo_ordinates((i * 3) -2);
    t_vertices(i).y := t_lrs_line.sdo_ordinates((i * 3) -1);
    t_vertices(i).distance := t_lrs_line.sdo_ordinates(i * 3);
  end loop;
  
  -- Shift as Needed
  if t_point_dist = 0 then
    t_result := LINE__INSERT_POINT_AT_INDEX(p_line, p_point, 1);
  elsif t_point_dist = t_line_dist then
    t_result := LINE__INSERT_POINT_AT_INDEX(p_line, p_point, (p_line.sdo_ordinates.count() / 2 + 1));
  else
    for i in 1..t_vertices.count() loop
      if t_point_dist > t_vertices(i).distance and t_point_dist < t_vertices(i + 1).distance then
        t_result := LINE__INSERT_POINT_AT_INDEX(p_line, p_point, i + 1);
      elsif t_point_dist = t_vertices(i).distance then
        t_result := LINE__INSERT_POINT_AT_INDEX(p_line, p_point, i + 1);
      end if;
    end loop;
  end if;
  
  return t_result;
  
end;