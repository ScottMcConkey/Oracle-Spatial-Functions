/*******************************************************************************
* LINE__SLICE()
*   Returns a Line Geometry consisting of a subselection of points based on 
*   the specified Start and End index parameters. When the End Index
*   is lower than the Start index, the direction is reversed and the
*   resultant geometry will contain the points in the opposite order of the
*   parent line.
*******************************************************************************/
function LINE__SLICE(p_line sdo_geometry, p_idx_start pls_integer, p_idx_end integer)
return sdo_geometry
is
  func_geometry_error exception;
  pragma exception_init(func_geometry_error, -20001);
  type vertex_pair is record (x number, y number);
  type vertex_hashtable is table of vertex_pair index by pls_integer;
  
  t_vertices     vertex_hashtable;
  t_array        sdo_ordinate_array := sdo_ordinate_array();
  t_result       sdo_geometry;

begin

  -- Validate Line
  if p_line.sdo_gtype != '2002' then
    raise_application_error(-20001, 'The Line must have an SDO_GTYPE of 2002');
  end if;
  if mod(p_line.sdo_ordinates.count(), 2) != 0 then
    raise_application_error(-20001, 'Invalid number of vertices');
  end if;
  
  -- Validate Indices
  if p_idx_start <= 0 or p_idx_end <= 0 then
    raise_application_error(-20001, 'Index must be greater than 0');
  end if;
  if p_idx_start > (p_line.sdo_ordinates.count() / 2) or
     p_idx_end > (p_line.sdo_ordinates.count() / 2)  then
    raise_application_error(-20001, 'Index out of range');
  end if;
  if p_idx_start = p_idx_end then
    raise_application_error(-20001, 'Indices must not be equivalent');
  end if;
  
  -- Populate the Hashtable
  for i in 1..(p_line.sdo_ordinates.count() / 2) loop   
    t_vertices(i).x := p_line.sdo_ordinates((i * 2) -1);
    t_vertices(i).y := p_line.sdo_ordinates(i * 2);
  end loop;
  
  -- Slice
  if p_idx_start < p_idx_end then
    for i in p_idx_start .. p_idx_end loop
      t_array.extend(2);
      t_array(t_array.count() - 1) := t_vertices(i).x;
      t_array(t_array.count()) := t_vertices(i).y;
    end loop;
  else
    for i in reverse p_idx_end .. p_idx_start loop
      t_array.extend(2);
      t_array(t_array.count() - 1) := t_vertices(i).x;
      t_array(t_array.count()) := t_vertices(i).y;
    end loop;
  end if;
  
  t_result := sdo_geometry(p_line.sdo_gtype, p_line.sdo_srid, null, p_line.sdo_elem_info, t_array);
  
  return t_result;
  
end;