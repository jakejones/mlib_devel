function oversampling_pfb_fir_real_init(blk, varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Build & Initialise Oversampling PFB Module %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    % ------- Check correct mask type --------
    check_mask_type(blk, 'oversampling_pfb_fir_real_init');
    
    % ------- Disable library link before continuing --------
    munge_block(blk, varargin{:});

    % ------ Set default values ---------
    defaults = { ...
        'N',256,...
        'T',8,...
        'B',2,...
        'c_bits',12,...
        'in_bits',8,...
        'out_bits',16, ...
        'windowfunc', ones(1,256*8), ...
        'I', 1, ...
        'done',0 ...
        'F', 1.28, ...
      };  

    % ------ get variables from mask ------
    N           = get_var('N','defaults',defaults,varargin{:});
    T           = get_var('T','defaults',defaults,varargin{:});
    B           = get_var('B','defaults',defaults,varargin{:});  
    c_bits      = get_var('c_bits','defaults',defaults,varargin{:}); 
    in_bits     = get_var('in_bits','defaults',defaults,varargin{:});
    out_bits    = get_var('out_bits','defaults',defaults,varargin{:});
    windowfunc  = get_var('windowfunc','defaults',defaults,varargin{:});
    done        = get_var('done','defaults',defaults,varargin{:});
    I           = get_var('I','defaults',defaults,varargin{:});
    F           = get_var('F','defaults',defaults,varargin{:});

    fmtstr = sprintf('channels=%d, taps=%d,\n oversampling_factor=%0.3f, inputs=%d',N,T,F,I);
    set_param(blk, 'AttributesFormatString', fmtstr);

    % ----- Don't re-exucute this function if done is true ------
    % -- This is usefull when the design becomes very large and things get slow ----
    if done, return, end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % First, delete any oversampling_pfb_fir_tap blocks that may exist
    delete_all_of_type(blk,'oversampling_pfb_tap');

    pos_x = 0;
    pos_y = 0;
    width = 130;
    height = 300;

    for i=0:(T-1)

       reuse_block(blk, ['tap', mat2str(i)], 'casper_library_pfbs/oversampling_pfb_tap', ...
        'N', mat2str(N), ...
        'T', mat2str(T), ...
        'B', mat2str(B), ...
        'in_bits', mat2str(in_bits), ...
        'c_bits', mat2str(c_bits), ...
        'out_bits', mat2str(out_bits), ...
        'coeffs', ['oversampling_pfb_coeff_gen(', windowfunc ,',c_bits, B , T ,', mat2str(i) ,')'] , ...
        'd', mat2str( oversampling_pfb_coeff_divisor( windowfunc , N ) ), ...
        'I', mat2str(I), ...
        'Position', [pos_x-width/2 pos_y-height/2 pos_x+width/2 pos_y+height/2]...
        ); 

        if i==0
            add_line(blk, 'ospfb_control_unit/1', ['tap', mat2str(i),'/1']); 
            add_line(blk, 'ospfb_control_unit/2', ['tap', mat2str(i),'/2']); 
            add_line(blk, 'ospfb_control_unit/3', ['tap', mat2str(i),'/3']); 
            add_line(blk, 'ospfb_control_unit/4', ['tap', mat2str(i),'/4']); 
            add_line(blk, 'ospfb_control_unit/5', ['tap', mat2str(i),'/5']);
        else
            add_line(blk, ['tap', mat2str(i-1),'/1'], ['tap', mat2str(i),'/1']); 
            add_line(blk, ['tap', mat2str(i-1),'/2'], ['tap', mat2str(i),'/2']);
            add_line(blk, ['tap', mat2str(i-1),'/3'], ['tap', mat2str(i),'/3']);
            add_line(blk, ['tap', mat2str(i-1),'/4'], ['tap', mat2str(i),'/4']);
            add_line(blk, ['tap', mat2str(i-1),'/5'], ['tap', mat2str(i),'/5']);
        end

        if i==(T-1)

            % ---- Change position of phase rotator & out ports ----
            pos_x = pos_x + 150;
            height = 360;
            width = 100;
            set_param([blk,'/phase_rotator'], 'Position', [pos_x-width/2 pos_y-height/2 pos_x+width/2 pos_y+height/2] )

            pos_x = pos_x + 100;
            y1 = -120;
            y2 = 0;
            y3 =  120;
            set_param([blk,'/sync_out'], 'Position', [pos_x-20/2 y1-10/2 pos_x+20/2 y1+10/2] )
            set_param([blk,'/dvalid_out'], 'Position', [pos_x-20/2 y2-10/2 pos_x+20/2 y2+10/2] )
            set_param([blk,'/data_out'], 'Position', [pos_x-20/2 y3-10/2 pos_x+20/2 y3+10/2] )

            % ---- Connect the outports -----
            add_line(blk, ['tap', mat2str(i),'/1'], 'phase_rotator/1'); 
            add_line(blk, ['tap', mat2str(i),'/4'], 'phase_rotator/2');
            add_line(blk, ['tap', mat2str(i),'/5'], 'phase_rotator/3'); 
        end

        pos_x = pos_x + 160;

    end

    % When finished drawing blocks and lines, remove all unused blocks.
    clean_blocks(blk);

    % Save and back-populate mask parameter values
    save_state(blk, 'defaults', defaults, varargin{:});  
  
end
