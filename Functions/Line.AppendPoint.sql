function LINE__APPEND_POINT(p_line sdo_geometry, p_point sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);

  t_array mdsys.sdo_ordinate_array;
  t_result sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  
  -- Validate Point
  if p_point.sdo_gtype != '2001' then
    raise_application_error(-20001, 'The Point must have an SDO_GTYPE of 2001');
  end if;
  
  t_array := p_line.sdo_ordinates;
  t_array.extend(2);
  t_array(t_array.count() - 1) := p_point.sdo_point.x;
  t_array(t_array.count()) := p_point.sdo_point.y;
  
  t_result := sdo_geometry(p_line.sdo_gtype, p_line.sdo_srid, null, p_line.sdo_elem_info, t_array);

  return t_result;
  
end;