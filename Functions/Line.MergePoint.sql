/*******************************************************************************
* LINE__MERGE_POINT()
*   Merges a point into the SDO_ORDINATES of a Line based upon
*   proximity  to the line.
*
*   1. A Point whose closest location on the Line matches the FIRST  
*      coordinates of that Line is added to the beginning of the line.
*   2. A Point whose closest location on the Line matches the FINAL 
*      coordinates of that Line is added to the end of the line.
*   3. A Point whose closest location on the Line is BETWEEN two other
*      coordinates of that Line is added between the two, at the index of the
*      latter, maintaining the rest of the Line behind it.
*   4. A Point whose closest location on the Line MATCHES specific coordinates
*      of that line is added after those coordinates, maintaining the rest of
*      the line behind it.
*
* !!! You must include a copy of LINE__INSERT_POINT_AT_INDEX() or this
* !!! Function will not work
*******************************************************************************/
function LINE__MERGE_POINT(p_line sdo_geometry, p_point sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  
  type lrs_vertex_pair is record (x number, y number, distance number);
  type lrs_vertex_hashtable is table of lrs_vertex_pair index by pls_integer;
  t_vertices lrs_vertex_hashtable;
  t_new_vertices lrs_vertex_hashtable;
  
  t_lrs_line sdo_geometry := sdo_lrs.convert_to_lrs_geom(p_line);
  t_lrs_point sdo_geometry := sdo_lrs.convert_to_lrs_geom(p_point);

  t_x number := t_lrs_point.sdo_point.x;
  t_y number := t_lrs_point.sdo_point.y;
  
  t_point_dist number := sdo_lrs.project_pt(t_lrs_line, p_point).sdo_ordinates(3);
  t_line_dist number := t_lrs_line.sdo_ordinates(t_lrs_line.sdo_ordinates.count()); -- get the last ordinate, which is distance for final point
  
  t_idx number;
  
  t_result sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  
  -- Validate Point
  if p_point.sdo_gtype not in ('2001', '2002') then
    raise_application_error(-20001, 'The Point must have an SDO_GTYPE of 2001 or 2002');
  end if;
  if p_point.sdo_gtype = '2002' and p_point.sdo_ordinates.exists(3) then
    raise_application_error(-20001, 'The Point must not be a Line with more than 2 ordinates');
  end if;
  
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