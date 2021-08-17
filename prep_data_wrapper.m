if component == 23; % Combine horizontal components 1 and 2. 
%     disp('Component 23'); 
    
    component = 2; 
    prep_data; 
    
    datMerge = dat;
    OthVarMatMerge = OthVarMat; 
    catsMerge = cats; 
    
    component = 3; 
    prep_data; 
    dat = [datMerge; dat]; 
    OthVarMat = [OthVarMatMerge, OthVarMat]; 
    catsMerge(7 ).data = [catsMerge(7 ).data cats(7 ).data];
    catsMerge(8 ).data = [catsMerge(8 ).data cats(8 ).data];
    catsMerge(9 ).data = [catsMerge(9 ).data cats(9 ).data];
    catsMerge(10).data = [catsMerge(10).data cats(10).data];
    catsMerge(11).data = [catsMerge(11).data cats(11).data];
    cats = catsMerge; 
    
    
else
    if strcmp(coh_or_spec, 'coh'); 
        prep_data_coh; 
    else
        prep_data; 
    end
end