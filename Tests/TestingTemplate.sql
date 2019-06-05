declare
  t_line sdo_geometry := MDSYS.SDO_GEOMETRY(2002, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(1,1, 3,1, 4,1, 5,1));
  t_point sdo_geometry := MDSYS.SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(6,2,null), null, null);
  
  t_result sdo_geometry;
  
    function LINE__INSERT_POINT_AT_INDEX(p_line sdo_geometry, p_point sdo_geometry, p_idx number)
    return sdo_geometry
    is
      func_geometry_error exception;
      pragma exception_init(func_geometry_error, -20001);
      
      type vertex_pair is record (x number, y number);
      type vertex_hashtable is table of vertex_pair index by pls_integer;
      t_vertices vertex_hashtable;
      t_new_vertices vertex_hashtable;
      t_new_array sdo_ordinate_array := sdo_ordinate_array();
      t_new_line sdo_geometry;
    
    
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
      
      -- Validate Index
      if p_idx <= 0 then
        raise_application_error(-20001, 'Index must be greater than 0');
      end if;
      if p_line.sdo_ordinates.count() / 2  + 1 < p_idx then
        raise_application_error(-20001, 'Index out of range. You may only specify an index up to 1 greater than the maximum');
      end if;
      
      -- Populate the Hashtable
      for i in 1..(p_line.sdo_ordinates.count() / 2) loop
        t_vertices(i).x := p_line.sdo_ordinates((i * 2) -1);
        t_vertices(i).y := p_line.sdo_ordinates(i * 2);
      end loop;
      
      -- Copy the Hashtable
      for i in 1..t_vertices.count() loop
        t_new_vertices(i).x := t_vertices(i).x;
        t_new_vertices(i).y := t_vertices(i).y;
      end loop;
      
      
      -- Insert (slow!)
      for i in p_idx .. t_vertices.count() loop
        t_new_vertices(i + 1).x := t_vertices(i).x;
        t_new_vertices(i + 1).y := t_vertices(i).y;
      end loop;
      
      -- Add Point at Index
      t_new_vertices(p_idx).x := p_point.sdo_point.x;
      t_new_vertices(p_idx).y := p_point.sdo_point.y;
      
      -- Convert Hashtable to Ordinate Array
      for i in 1..t_new_vertices.count() loop
        t_new_array.extend(2);
        t_new_array(t_new_array.count() - 1) := t_new_vertices(i).x;
        t_new_array(t_new_array.count()) := t_new_vertices(i).y;
      end loop;
      
      -- Convert to Line Geometry
      t_new_line := SDO_GEOMETRY(2002, p_line.sdo_srid, null, p_line.sdo_elem_info, t_new_array);
      
      return t_new_line;
      
    end;
  
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

begin
  t_result := LINE__MERGE_POINT(t_line, t_point);
  
  for i in 1..t_result.sdo_ordinates.count() loop
    dbms_output.put_line(t_result.sdo_ordinates(i));
  end loop;
  
  
end;