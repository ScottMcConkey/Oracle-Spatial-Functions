function LINE__COORDINATE_COUNT(p_line sdo_geometry)
return number
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);

  t_count number;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  
  t_count := p_line.sdo_ordinates.count() / 2;

  return t_count;
  
end;