function delete_all_of_type(cursys, type)

    try
        % ------- iterate over all blocks and delete all blpocks of a certain mask type ------
        blocks = get_param(cursys, 'Blocks');
        for i=1:length(blocks)
            blk = [cursys,'/',blocks{i}];
            if strcmp( get_param(blk, 'MaskType') , type)
                delete_block_lines(blk);
                delete_block(blk);
            end
        end
    catch ex
        dump_and_rethrow(ex);
    end

end

