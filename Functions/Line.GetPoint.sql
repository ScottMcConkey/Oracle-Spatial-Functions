function LINE__GET_POINT(p_line sdo_geometry, p_idx pls_integer)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  
  type vertex_pair is record (x number, y number);
  type vertex_hashtable is table of vertex_pair index by pls_integer;
  t_vertices vertex_hashtable;
  t_new_point sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  
  -- Validate Index
  if p_idx <= 0 then
    raise_application_error(-20001, 'Index must be greater than 0');
  end if;
  if p_line.sdo_ordinates.count() / 2 < p_idx then
    raise_application_error(-20001, 'Index out of range');
  end if;
  
  -- Populate the Hashtable
  for i in 1..(p_line.sdo_ordinates.count() / 2) loop
    t_vertices(i).x := p_line.sdo_ordinates((i * 2) -1);
    t_vertices(i).y := p_line.sdo_ordinates(i * 2);
  end loop;
  
  -- Set up Point
  t_new_point := SDO_GEOMETRY(2001, p_line.sdo_srid, SDO_POINT_TYPE(t_vertices(p_idx).x, t_vertices(p_idx).y, null), null, null);
  
  return t_new_point;
  
end;