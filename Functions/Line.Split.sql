/*******************************************************************************
* LINE__SPLIT()
*******************************************************************************/
procedure LINE__SPLIT(p_line sdo_geometry, p_idx pls_integer, r_line_1 out sdo_geometry, r_line_2 out sdo_geometry)
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  type vertex_pair is record (x number, y number);
  type vertex_hashtable is table of vertex_pair index by pls_integer;
  t_vertices     vertex_hashtable;

begin
  
  r_line_1 := sdo_geometry(2002, p_line.sdo_srid, null, p_line.sdo_elem_info, sdo_ordinate_array());
  r_line_2 := sdo_geometry(2002, p_line.sdo_srid, null, p_line.sdo_elem_info, sdo_ordinate_array());

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
  for i in 1..(t_line.sdo_ordinates.count() / 2) loop   
    t_vertices(i).x := t_line.sdo_ordinates((i * 2) -1);
    t_vertices(i).y := t_line.sdo_ordinates(i * 2);
  end loop;
  
  -- Split
  for i in 1 .. p_idx loop
    r_line_1.sdo_ordinates.extend(2);
    r_line_1.sdo_ordinates(r_line_1.sdo_ordinates.count() - 1) := t_vertices(i).x;
    r_line_1.sdo_ordinates(r_line_1.sdo_ordinates.count()) := t_vertices(i).y;
  end loop;
  for i in p_idx .. t_vertices.count() loop
    r_line_2.sdo_ordinates.extend(2);
    r_line_2.sdo_ordinates(r_line_2.sdo_ordinates.count() - 1) := t_vertices(i).x;
    r_line_2.sdo_ordinates(r_line_2.sdo_ordinates.count()) := t_vertices(i).y;
  end loop;
  
end;