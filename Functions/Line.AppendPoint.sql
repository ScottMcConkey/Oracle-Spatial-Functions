function LINE__APPEND_POINT(p_line sdo_geometry, p_point sdo_geometry)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);

  t_new_array mdsys.sdo_ordinate_array;
  t_new_geom sdo_geometry;
  t_count number;
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
  
  t_new_array := p_line.sdo_ordinates;
  t_count := t_new_array.count();
  t_new_array.extend(2);
  
  if p_point.sdo_gtype = '2001' then
      t_new_array(t_count + 1) := p_point.sdo_point.x;
      t_new_array(t_count + 2) := p_point.sdo_point.y;
  elsif p_point.sdo_gtype = '2002' then
      t_new_array(t_count + 1) := p_point.sdo_ordinates(1);
      t_new_array(t_count + 2) := p_point.sdo_ordinates(2);
  end if;
  
  t_new_geom := sdo_geometry(p_line.sdo_gtype, p_line.sdo_srid, null, p_line.sdo_elem_info, t_new_array);

  return t_new_geom;
  
end;



function APPEND_POINT(p_line sdo_geometry, p_x_coord number, p_y_coord number)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);

  t_new_array mdsys.sdo_ordinate_array;
  t_new_geom sdo_geometry;
  t_count number;
begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  
  t_new_array := p_line.sdo_ordinates;
  t_count := t_new_array.count();
  t_new_array.extend(2);
  

  t_new_array(t_count + 1) := p_x_coord;
  t_new_array(t_count + 2) := p_y_coord;

  t_new_geom := sdo_geometry(p_line.sdo_gtype, p_line.sdo_srid, null, p_line.sdo_elem_info, t_new_array);

  return t_new_geom;
  
end;



function APPEND_POINT(p_line sdo_geometry, p_point sdo_point_type)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);

  t_new_array mdsys.sdo_ordinate_array;
  t_new_geom sdo_geometry;
  t_count number;
begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  
  t_new_array := p_line.sdo_ordinates;
  t_count := t_new_array.count();
  t_new_array.extend(2);
  

  t_new_array(t_count + 1) := p_point.x;
  t_new_array(t_count + 2) := p_point.y;

  t_new_geom := sdo_geometry(p_line.sdo_gtype, p_line.sdo_srid, null, p_line.sdo_elem_info, t_new_array);

  return t_new_geom;
  
end;