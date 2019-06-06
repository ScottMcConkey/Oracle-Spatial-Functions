function LINE__TO_POINT(p_line sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  t_result sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  if p_line.sdo_ordinates.count() > 2 then
    raise_application_error(-20001, 'The Line must not have more than two Ordinates');
  end if;
  
  t_result := sdo_geometry(2001, p_line.sdo_srid, sdo_point_type(p_line.sdo_ordinates(1), p_line.sdo_ordinates(2), null), null, null);

  return t_result;
  
end;