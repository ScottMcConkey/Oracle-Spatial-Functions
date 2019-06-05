function LINE__REPLACE_POINT_AT_INDEX(p_line sdo_geometry, p_idx number, p_point sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  
  type vertex_pair is record (x number, y number);
  type vertex_hashtable is table of vertex_pair index by pls_integer;
  t_vertices vertex_hashtable;
  t_new_array sdo_ordinate_array := sdo_ordinate_array();
  t_new_line sdo_geometry;


begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  
  -- Validate Index
  if p_idx <= 0 then
    raise_application_error(-20001, 'Index must be greater than 0');
  end if;
  if p_line.sdo_ordinates.count() / 2 < p_idx then
    raise_application_error(-20001, 'Index out of range');
  end if;
  
  -- Validate Point
  if p_point.sdo_gtype not in ('2001', '2002') then
    raise_application_error(-20001, 'The Point must have an SDO_GTYPE of 2001 or 2002');
  end if;
  if p_point.sdo_gtype = '2002' and p_point.sdo_ordinates.exists(3) then
    raise_application_error(-20001, 'The Point must not be a Line with more than 2 ordinates');
  end if;
  
  -- Populate the Hashtable
  for i in 1..(p_line.sdo_ordinates.count() / 2) loop
    t_vertices(i).x := p_line.sdo_ordinates((i * 2) -1);
    t_vertices(i).y := p_line.sdo_ordinates(i * 2);
  end loop;
  
  -- Replace the Hashtable Values
  t_vertices(p_idx).x := p_point.sdo_point.x;
  t_vertices(p_idx).y := p_point.sdo_point.y;
  
  -- Convert Hashtable to Ordinate Array
  for i in 1..t_vertices.count() loop
    t_new_array.extend(2);
    t_new_array(t_new_array.count() - 1) := t_vertices(i).x;
    t_new_array(t_new_array.count()) := t_vertices(i).y;
  end loop;
  
  -- Convert to Line Geometry
  t_new_line := SDO_GEOMETRY(2002, p_line.sdo_srid, null, p_line.sdo_elem_info, t_new_array);
  
  return t_new_line;
  
end;