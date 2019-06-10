function LINE__GET_INDEX(p_line sdo_geometry, p_point sdo_geometry)
return pls_integer --returns null if no result found
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  
  type vertex_pair is record (x number, y number);
  type vertex_hashtable is table of vertex_pair index by pls_integer;
  t_vertices vertex_hashtable;
  t_index pls_integer := null;

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
  for i in 1..(p_line.sdo_ordinates.count() / 2) loop
    t_vertices(i).x := p_line.sdo_ordinates((i * 2) -1);
    t_vertices(i).y := p_line.sdo_ordinates(i * 2);
  end loop;
  
  -- Search Hashtable for Point Values
  -- Basic search, probably super slow
  -- Note this matches the first occurance. If a second occurance is somehow valid, it
  -- will not be returned.
  for i in 1..t_vertices.count() loop
    if t_vertices(i).x = p_point.sdo_point.x then
      if t_vertices(i).y = p_point.sdo_point.y then
        t_index := i;
        exit;
      end if;
    end if;
  end loop;
  
  return t_index;
  
end;