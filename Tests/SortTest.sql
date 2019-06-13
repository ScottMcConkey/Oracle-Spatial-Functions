/*******************************************************************************
* POINT_ARRAY__SORT()
*******************************************************************************/
declare
    t_line sdo_geometry := MDSYS.SDO_GEOMETRY(2002, NULL, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(5,1, 4,3, 8,2, 9,1));
    type geometry_array is varray(2147483647) of sdo_geometry;
    t_points geometry_array := geometry_array(
      sdo_geometry(2001, null, sdo_point_type(1,1, null), null, null),
      sdo_geometry(2001, null, sdo_point_type(10,10, null), null, null),
      sdo_geometry(2001, null, sdo_point_type(8,8, null), null, null),
      sdo_geometry(2001, null, sdo_point_type(9,9, null), null, null),
      sdo_geometry(2001, null, sdo_point_type(3,3, null), null, null)
    );
    
    t_results geometry_array := geometry_array();
    
    /*******************************************************************************
    * LINE__PROJECTION_SPLIT()
    *   Takes a Line and splits it into multiple Lines based upon the PROJECTION
    *   of Points along that Line. This means that a Line may be split on a 
    *   Point that does not touch that line, but the actual shape will not be 
    *   modified. See the SDO_LRS.PROJECT_PT function for more information.
    *******************************************************************************/
    type number_array is varray(500) of number;
    
    -- snagged from http://www.octopusfunda.com/2015/07/quick-sort-in-plsql.html
    PROCEDURE QUICK_SORT(arr in out number_array,first number,last number)
    IS
     pivot number:=first;
     i number:=first;
     j number:=last;
     temp number;
    BEGIN
      while i<j loop
        while arr (i) <= arr (pivot) loop
          if i<last then 
            i:=i+1;
          else  
            EXIT WHEN i>=last;
          end if; 
      end loop;
      while arr(j) > arr(pivot) loop
        if j>first then 
          j:=j-1;
        else  
          EXIT WHEN j<=first;
        end if; 
      end loop;
      if i<j then
        temp := arr(i);
        arr(i) := arr(j);
        arr(j) :=temp;
      elsif i>=j then
        temp := arr(pivot);
        arr(pivot) := arr(j);
        arr(j) := temp;
      end if;
      end loop;
      if j-1 > 1 then
        QUICK_SORT(arr,1,j-1);
      end if;
      if  j+1 < last then
        QUICK_SORT(arr,j+1,last); 
      end if; 
    END QUICK_SORT;
    
    function LINE__PROJECTION_SPLIT(p_line sdo_geometry, p_points geometry_array)
    return geometry_array
    is
      func_geometry_error exception;
      pragma exception_init(func_geometry_error, -20001);
      type point_data is record (x number, y number, d number);
      type point_table is table of point_data;
      
      t_distances    number_array := number_array();
      t_lrs_line     sdo_geometry;
      t_sdo_point    sdo_geometry;
    
    begin
    
      -- Validate Line
      if p_line.sdo_gtype != '2002' then
        raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
      end if;
      if mod(p_line.sdo_ordinates.count(), 2) != 0 then
        raise_application_error(-20001, 'Invalid number of vertices');
      end if;
      
      -- Validate Point Array
      for i in 1..p_points.count() loop
        if p_points(i).sdo_gtype != '2001' then
          raise_application_error(-20001, 'Each Point must have an SDO_GTYPE of 2001');
        end if;  
      end loop;
      
      t_lrs_line := sdo_lrs.convert_to_lrs_geom(p_line);
      
      -- Populate Point Table
      for i in 1..p_points.count() loop
        t_sdo_point := sdo_lrs.project_pt(t_lrs_line, sdo_lrs.convert_to_lrs_geom(p_points(i)));
        t_distances.extend(1);
        t_distances(t_distances.count()) := t_sdo_point.sdo_ordinates(3);
      end loop;
      
      -- Sort the Points by their proximity to the start of the line
      QUICK_SORT(t_distances, 1, t_distances.count());
      
      -- Create Lines
      for i in 1..t_distances.count() loop
        t_results.extend(1);
        if i = 1 then
          t_results(t_results.count()) := sdo_lrs.convert_to_std_geom(sdo_lrs.clip_geom_segment(sdo_lrs.convert_to_lrs_geom(t_line), 0, t_distances(i)));
        else
          t_results(t_results.count()) := sdo_lrs.convert_to_std_geom(sdo_lrs.clip_geom_segment(sdo_lrs.convert_to_lrs_geom(t_line), t_distances(i-1), t_distances(i)));
        end if;
      end loop;
        
      return t_results;

    end;

begin
  
  t_results := LINE__PROJECTION_SPLIT(t_line, t_points);
  
  for i in 1..t_results.count() loop
    dbms_output.put_line('Element #' || i ||': ');
    for k in 1..t_results(i).sdo_ordinates.count() loop
      dbms_output.put_line(t_results(i).sdo_ordinates(k));
    end loop;
    dbms_output.put_line('');
  end loop;
  
  
end;