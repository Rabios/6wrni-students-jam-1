def play_back_sound args
  args.audio[:back] ||= {
    input: "audio/538548__sjonas88__select-3.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_success_sound args
  args.audio[:success] ||= {
    input: "audio/sfx_zap.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_select_sound args
  args.audio[:select] ||= {
    input: "audio/399934__old-waveplay__perc-short-click-snap-perc.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_click_sound args
  args.audio[:click] ||= {
    input: "audio/39562__the-bizniss__mouse-click.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def AABB(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2
end

def arr_match(arr1, arr2)
  if arr1.length != arr2.length
    return false
  else
    matches = 0
    
    arr1.length.times.map do |i|
      if arr1[i] == arr2[i]
        matches += 1
      end
    end
    
    return matches == arr1.length
  end
end

def all_puzzles_passed(args)
  return arr_match(args.state.puzzles_done, [ 1, 1, 1, 1, 1, 1, 1, 1 ])
end

def randbit args
  masks = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
  
  res = 0
  
  masks.length.times.map do |i|
    masks[i] = rand(2)
    
    if masks[i] == 1
      res += args.state.bitmasks[i]
    end
  end
  
  return res
end

def num_to_color(n)
  arr = [
    { r: 255, g: 0, b: 0, a: 255 },
    { r: 0, g: 255, b: 0, a: 255 },
    { r: 0, g: 0, b: 255, a: 255 },
    { r: 255, g: 0, b: 255, a: 255 },
  ]
  
  return arr[n]
end

def get_col(a, n)
  res = []
  
  a.length.times.map do |i|
    res[i] = a[i][n]
  end
  
  return res
end

def get_row(a, n)
  return a[n]
end

def matches(a, n)
  res = 0
  
  a.length.times.map do |i|
    if (a[i] == n)
      res += 1
    end
  end
  
  return res
end

def rand_pattern
  patterns = [
    [ 0, 1, 2, 3 ], [ 0, 1, 3, 2 ], [ 0, 2, 1, 3 ],
    [ 0, 2, 3, 1 ], [ 0, 3, 1, 2 ], [ 0, 3, 2, 1 ],
      
    [ 1, 0, 2, 3 ], [ 1, 0, 3, 2 ], [ 1, 2, 0, 3 ],
    [ 1, 2, 3, 0 ], [ 1, 3, 2, 0 ], [ 1, 3, 0, 2 ],
      
    [ 2, 0, 1, 3 ], [ 2, 0, 3, 1 ], [ 2, 1, 0, 3 ],
    [ 2, 1, 3, 0 ], [ 2, 3, 0, 1 ], [ 2, 3, 1, 0 ],
      
    [ 3, 0, 1, 2 ], [ 3, 0, 2, 1 ], [ 3, 1, 0, 2 ],
    [ 3, 1, 2, 0 ], [ 3, 2, 0, 1 ], [ 3, 2, 1, 0 ],
  ]
  
  return patterns[rand(patterns.length)]
end

def mouse_click_input args
  args.state.clicks += 1
  play_click_sound args
  
  if (args.state.clicks == 1)
    args.state.first_rec = {
      col: args.state.mouse_col,
      row: args.state.mouse_row,
      color: args.state.grid[args.state.mouse_col][args.state.mouse_row]
    }
  elsif (args.state.clicks == 2)
    args.state.second_rec = {
      col: args.state.mouse_col,
      row: args.state.mouse_row,
      color: args.state.grid[args.state.mouse_col][args.state.mouse_row]
    }
    args.state.grid[args.state.first_rec.col][args.state.first_rec.row] = args.state.second_rec.color
    args.state.grid[args.state.second_rec.col][args.state.second_rec.row] = args.state.first_rec.color;
    args.state.clicks = 0
    clicks = 0
  end
end

def mouse_move args
  args.state.grid.length.times.map do |i|
    args.state.grid[i].length.times.map do |j|
      if (AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, 368 + (j * 128), 64 + (i * 128), 128, 128))
        args.state.mouse_col = i
        args.state.mouse_row = j
      end
    end
  end
end

def tick args
  setup args
  
  if args.state.scene == 0
    menu args
  elsif args.state.scene == 1
    game args
  elsif args.state.scene == 2
    puzzle args
  elsif args.state.scene == 3
    credits args
  end
end

def setup args
  args.state.scene              ||= 0
  args.state.clicks             ||= 0
  args.state.selection          ||= 0
  args.state.mouse_col          ||= 0
  args.state.mouse_row          ||= 0
  args.state.rooms              ||= []
  args.state.puzzles_done       ||= [ 0, 0, 0, 0, 0, 0, 0, 0 ]
  args.state.bitmasks           ||= [ 1, 2, 4, 8, 16, 32, 64, 128 ]
  args.state.puzzle_masks       ||= [ 0, 0, 0, 0, 0, 0, 0, 0 ]
  args.state.txt                ||= ""
  args.state.player_x           ||= (496 / 2) - 32
  args.state.player_y           ||= (496 / 2)
  args.state.current_puzzle     ||= 0
  args.state.bitval             ||= randbit(args)
  args.state.first_rec          ||= {}
  args.state.second_rec         ||= {}
  args.state.room_deadline      ||= args.state.room_count
  args.state.goals              ||= [
    "ORDER COLORS TO BE NOT DUPLICATED ON ALL COLUMNS AND ROWS",
    "SET BITS TO MATCH NUMBER ON OTHER SIDE",
    "FILL GRID SO NO TRACE LEFT",
    "COUNT COLORS",
    "SOLVE THIS SUDOKU PUZZLE",
    "MAGIC SQUARE",
    "FILL WITH NUMBERS TO COMPLETE PYRAMID OF NUMBERS",
    "FILL VIA PRESSING ARROWS TO NAVIGATE INTO THE TARGET",
  ]
  args.state.board              ||= {
    x: 392,
    y: 104,
    w: 496,
    h: 496,
    r: 255
  }
  args.state.rooms_recs     ||= []
  args.state.rooms_texts    ||= []
  args.state.grid ||= [
    rand_pattern,
    rand_pattern,
    rand_pattern,
    rand_pattern,
  ]
  args.state.fillgrid ||= [
    [ 2, 0, 0, 2 ],
    [ 0, 0, 0, 1 ],
    [ 0, 2, 0, 2 ],
    [ 0, 0, 0, 2 ]
  ]
  args.state.fillgrid_col ||= 1
  args.state.fillgrid_row ||= 3
  args.state.sudogrid ||= [
    [ 0, 0, 10, 10 ],
    [ 0, 0, 10, 0 ],
    [ 10, 0, 10, 10 ],
    [ 10, 10, 0, 0 ]
  ]
  
  args.state.pyramid ||= [
    [ 113 ],
    [ 64, 49 ],
    [ 37, 27, 22 ],
    [ 21, 16, 11, 11 ],
    [ 11, 10, 0, 0, 0 ],
    [ 0, 0, 0, 0, 0, 0 ]
  ]
  
  args.state.keys ||= [
    [ -1, -1, -1, 0 ],
    [ 0, 0, 0, 0 ],
    [ 0, -1, 5, 0 ],
    [ 0, 0, 0, 0 ],
  ]
  args.state.track_keys ||= [
    { c: 0, r: 3 },
    { c: 1, r: 0 },
    { c: 1, r: 1 },
    { c: 1, r: 2 },
    { c: 1, r: 3 },
    { c: 2, r: 0 },
    { c: 2, r: 3 },
    { c: 3, r: 0 },
    { c: 3, r: 1 },
    { c: 3, r: 2 },
    { c: 3, r: 3 },
  ]
  args.state.track_index ||= 0
  args.state.trackkey ||= args.state.track_keys[args.state.track_index]
  
  5.times.map do |i|
    args.state.rooms_recs[i] ||= {
      x: args.state.board.x + 32,
      y: args.state.board.y + (256 + 120) - (i * 82),
      w: 64,
      h: 64,
      r: (args.state.puzzles_done[i] == 0) ? 255 : 0,
      g: 0,
      b: (args.state.puzzles_done[i] == 1) ? 255 : 0,
      a: 255
    }
    args.state.rooms_texts[i] ||= {
      x: args.state.board.x + 52,
      y: args.state.board.y + (256 + 170) - (i * 82),
      text: i + 1,
      size_enum: 8,
      r: (args.state.puzzles_done[i] == 0) ? 255 : 0,
      g: 0,
      b: (args.state.puzzles_done[i] == 1) ? 255 : 0,
      a: 255
    }
  end
  
  3.times.map do |i|
    args.state.rooms_recs[5 + i] ||= {
      x: args.state.board.x + 400,
      y: args.state.board.y + (256 + 120) - (i * 82),
      w: 64,
      h: 64,
      r: (args.state.puzzles_done[5 + i] == 0) ? 255 : 0,
      g: 0,
      b: (args.state.puzzles_done[5 + i] == 1) ? 255 : 0,
      a: 255
    }
    args.state.rooms_texts[5 + i] ||= {
      x: args.state.board.x + 420,
      y: args.state.board.y + (256 + 170) - (i * 82),
      text: (5 + 1) + i,
      size_enum: 8,
      r: (args.state.puzzles_done[5 + i] == 0) ? 255 : 0,
      g: 0,
      b: (args.state.puzzles_done[5 + i] == 1) ? 255 : 0,
      a: 255
    }
  end
end

def menu args
  args.outputs.primitives << {
    x: 422,
    y: 32.from_top,
    text: "08-ROOMS",
    size_enum: 48,
    r: 255,
  }.label
  
  args.outputs.background_color = [ 0, 0, 0, 255 ]
  menu_texts = [ "START", "EXIT" ]
  
  args.outputs.primitives << {
    x: 0,
    y: ((args.state.selection * 64) + 628).from_top,
    w: 1280,
    h: 64,
    r: 255,
  }.solid
  
  menu_texts.length.times.map do |i|
    args.outputs.primitives << {
      x: 16,
      y: ((i * 64) + 576).from_top,
      text: menu_texts[i],
      size_enum: 8,
      r: 255,
      g: 255,
      b: 255,
      a: 255
    }.label
  end
  
  if args.inputs.keyboard.key_down.down
    play_select_sound args
    if args.state.selection + 1 > (menu_texts.length - 1)
      args.state.selection = 0
    else
      args.state.selection += 1
    end
  elsif args.inputs.keyboard.key_down.up
    play_select_sound args
    if args.state.selection - 1 < 0
      args.state.selection = (menu_texts.length - 1)
    else
      args.state.selection -= 1
    end
  elsif args.inputs.keyboard.key_down.enter
    play_select_sound args
    if args.state.selection == 1
      if $gtk.platform != "Emscripten"
        $gtk.exit
      end
    else
      args.state.scene = args.state.selection + 1
    end
    
    args.state.selection = 0
  end
end

def game args
  args.outputs.primitives << {
    x: 32,
    y: 32.from_top,
    text: "WELCOME TO HALL OF PUZZLES!",
    size_enum: 6,
    r: 255
  }.label
  
  args.outputs.background_color = [ 0, 0, 0, 255 ]
  args.outputs.primitives << args.state.board.border
  args.outputs.primitives << {
    x: args.state.player_x + args.state.board.x,
    y: args.state.player_y + args.state.board.y,
    w: 48,
    h: 48,
    r: 200,
    g: 0,
    b: 183,
  }.border
  
  if args.inputs.keyboard.up
    if AABB(args.state.board.x, args.state.board.y, args.state.board.w - 48, args.state.board.h - 48, (args.state.board.x + args.state.player_x), (args.state.board.y + (args.state.player_y + 4)), 48, 48)
      args.state.player_y += 4
    end
  end
  if args.inputs.keyboard.down
    if AABB(args.state.board.x, args.state.board.y + 48, args.state.board.w - 48, args.state.board.h - 48, (args.state.board.x + args.state.player_x), (args.state.board.y + (args.state.player_y - 4)), 48, 48)
      args.state.player_y -= 4
    end
  end
  if args.inputs.keyboard.left
    if AABB(args.state.board.x + 48, args.state.board.y, args.state.board.w, args.state.board.h - 48, (args.state.board.x + (args.state.player_x - 4)), (args.state.board.y + args.state.player_y), 48, 48)
      args.state.player_x -= 4
    end
  end
  if args.inputs.keyboard.right
    if AABB(args.state.board.x - 48, args.state.board.y, args.state.board.w, args.state.board.h - 48, (args.state.board.x + (args.state.player_x + 4)), (args.state.board.y + args.state.player_y), 48, 48)
      args.state.player_x += 4
    end
  end
  
  args.state.rooms_recs.length.times.map do |i|
    if args.state.puzzles_done[i] == 0
      args.outputs.primitives << args.state.rooms_recs[i].border
      args.outputs.primitives << args.state.rooms_texts[i].label
    
      if AABB(args.state.player_x + args.state.board.x, args.state.player_y + args.state.board.y, 48, 48, args.state.rooms_recs[i].x, args.state.rooms_recs[i].y, args.state.rooms_recs[i].w, args.state.rooms_recs[i].h)
        args.state.current_puzzle = i
        args.state.scene = 2
        args.state.player_x = (496 / 2) - 32
        args.state.player_y = (496 / 2)
      end
    end
  end
  
  if all_puzzles_passed(args)
    args.outputs.primitives << {
      x: args.state.board.x + 400,
      y: args.state.board.y + (256 + 120) - (4 * 82),
      w: 64,
      h: 64,
      r: 255,
      g: 255
    }.border
    args.outputs.primitives << {
      x: args.state.board.x + 420,
      y: args.state.board.y + (256 + 170) - (4 * 82),
      text: "X",
      size_enum: 8,
      r: 255,
      g: 255
    }.label 
    
    if AABB(args.state.board.x + args.state.player_x, args.state.board.y + args.state.player_y, 48, 48, args.state.board.x + 400, args.state.board.y + (256 + 120) - (4 * 82), 64, 64)
      args.state.player_x = (496 / 2) - 32
      args.state.player_y = 696.from_top
      args.state.scene = 3
    end
  end
end

def puzzle args
  args.outputs.background_color = [ 0, 0, 0, 255 ]
  args.outputs.primitives << {
    x: 32,
    y: 32.from_top,
    text: args.state.goals[args.state.current_puzzle],
    size_enum: 8,
    r: 255
  }.label
  
  args.outputs.primitives << {
    x: 8,
    y: 32,
    text: "[ESCAPE]: BACK",
    size_enum: 2,
    r: 255
  }.label
  
  if args.state.current_puzzle == 0
    args.state.grid.length.times.map do |i|
      args.state.grid[i].length.times.map do |j|
        args.outputs.primitives << {
          x: 368 + (j * 128),
          y: 64 + (i * 128),
          w: 128,
          h: 128,
          r: num_to_color(args.state.grid[i][j]).r,
          g: num_to_color(args.state.grid[i][j]).g,
          b: num_to_color(args.state.grid[i][j]).b,
          a: num_to_color(args.state.grid[i][j]).a,
        }.solid
        
        args.outputs.primitives << {
          x: 368 + (j * 128),
          y: 64 + (i * 128),
          w: 128,
          h: 128,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
        }.border
      end
    end
    
    if args.inputs.mouse.click
      mouse_click_input args
    end
    
    mouse_move args
    
    v = 0
    args.state.grid.length.times.map do |i|
      args.state.grid[i].length.times.map do |j|
        if (matches(get_row(args.state.grid, i), j) == 1 && matches(get_col(args.state.grid, j), i) == 1)
          v += 1
        end
      end
    end
  
    if (v == args.state.grid.length * args.state.grid.length)
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[0] = 1
    end
  elsif args.state.current_puzzle == 1
    args.outputs.primitives << {
      x: 100,
      y: 308.from_top,
      text: "0x ",
      size_enum: 32,
      r: 255
    }.label
    
    args.state.puzzle_masks.length.times.map do |i|
      aabb_puzzle_mask = AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, 196 + (i * 96), 396.from_top, 96, 96)
      
      args.outputs.primitives << {
        x: 196 + (i * 96),
        y: 396.from_top,
        w: 96,
        h: 96,
        r: 255,
        b: aabb_puzzle_mask ? 255 : 0
      }.border
      
      args.outputs.primitives << {
        x: 222 + (i * 96),
        y: 248.from_top,
        text: args.state.bitmasks[i],
        size_enum: 8,
        r: 255,
        b: aabb_puzzle_mask ? 255 : 0
      }.label
      
      args.outputs.primitives << {
        x: 228 + (i * 96),
        y: 308.from_top,
        text: args.state.puzzle_masks[i],
        size_enum: 32,
        r: 255,
        b: aabb_puzzle_mask ? 255 : 0
      }.label
      
      if args.inputs.mouse.click
        if AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, 196 + (i * 96), 396.from_top, 96, 96)
          play_click_sound args
          args.state.puzzle_masks[i] = (args.state.puzzle_masks[i] == 0 ? 1 : 0)
        end
      end
    end
    
    args.outputs.primitives << {
      x: 228 + (8 * 96),
      y: 308.from_top,
      text: "= #{args.state.bitval}",
      size_enum: 32,
      r: 255
    }.label
    
    res = 0
    
    args.state.puzzle_masks.length.times.map do |i|
      if args.state.puzzle_masks[i] == 1
        res += args.state.bitmasks[i]
      end
    end
    
    if res == args.state.bitval
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[1] = 1
    end
  elsif args.state.current_puzzle == 2
    args.state.fillgrid.length.times.map do |i|
      args.state.fillgrid[i].length.times.map do |j|
        args.outputs.primitives << {
          x: 368 + (j * 128),
          y: 64 + (i * 128),
          w: 128,
          h: 128,
          r: (args.state.fillgrid[i][j] == 2) ? 0 : 255,
          g: (args.state.fillgrid[i][j] == 2) ? 0 : 255,
          b: (args.state.fillgrid[i][j] == 2) ? 255 : 255,
          a: 255,
        }.border
        
        if args.state.fillgrid[i][j] == 1
          args.outputs.primitives << {
            x: 376 + (j * 128),
            y: 72 + (i * 128),
            w: 112,
            h: 112,
            r: 255
          }.solid
        end
      end
    end
    
    args.outputs.primitives << {
      x: 376 + (args.state.fillgrid_row * 128),
      y: 72 + (args.state.fillgrid_col * 128),
      w: 112,
      h: 112,
      r: 255,
      b: 255
    }.solid
    
    if args.inputs.keyboard.key_down.left
      v = args.state.fillgrid[args.state.fillgrid_col][args.state.fillgrid_row - 1]
      if v
        if v != 2 && args.state.fillgrid_row - 1 >= 0
          play_select_sound args
          args.state.fillgrid[args.state.fillgrid_col][args.state.fillgrid_row - 1] = v == 0 ? 1 : 0
          args.state.fillgrid_row -= 1
        end
      end
    end
    
    if args.inputs.keyboard.key_down.right
      v = args.state.fillgrid[args.state.fillgrid_col][args.state.fillgrid_row + 1]
      if v
        if v != 2 && !(args.state.fillgrid_row + 1 > args.state.fillgrid[args.state.fillgrid_col].length - 1)
          play_select_sound args
          args.state.fillgrid[args.state.fillgrid_col][args.state.fillgrid_row + 1] = v == 0 ? 1 : 0
          args.state.fillgrid_row += 1
        end
      end
    end
    
    if args.inputs.keyboard.key_down.up
      if !(args.state.fillgrid_col + 1 > 3) # Placeholder to avoid errors...
        v = args.state.fillgrid[args.state.fillgrid_col + 1][args.state.fillgrid_row]
        if v
          if v != 2 && !(args.state.fillgrid_col + 1 > 3)
            play_select_sound args
            args.state.fillgrid[args.state.fillgrid_col + 1][args.state.fillgrid_row] = v == 0 ? 1 : 0
            args.state.fillgrid_col += 1
          end
        end
      end
    end
    
    if args.inputs.keyboard.key_down.down
      v = args.state.fillgrid[args.state.fillgrid_col - 1][args.state.fillgrid_row]
      if v
        if v != 2 && !(args.state.fillgrid_col - 1 < 0)
          play_select_sound args
          args.state.fillgrid[args.state.fillgrid_col - 1][args.state.fillgrid_row] = v == 0 ? 1 : 0
          args.state.fillgrid_col -= 1
        end
      end
    end
    
    res = 0
    
    args.state.fillgrid.length.times.map do |i|
      res += matches(get_col(args.state.fillgrid, i), 1)
    end
    
    if res == 11
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[2] = 1
    end
    
  elsif args.state.current_puzzle == 3
    charlist = [ "<", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ">>" ]
    charlist.length.times.map do |i|
      aabb_input_rec = AABB(225 + (i * 72), 28, 64, 64, args.inputs.mouse.x, args.inputs.mouse.y, 1, 1)
      
      args.outputs.primitives << {
        x: 225 + (i * 72),
        y: 28,
        w: 64,
        h: 64,
        r: 255,
        b: aabb_input_rec ? 255 : 0
      }.border
      
      args.outputs.primitives << {
        x: 250 + (i * 72),
        y: 76,
        text: charlist[i],
        size_enum: 8,
        r: 255,
        b: aabb_input_rec ? 255 : 0
      }.label
      
      args.outputs.primitives << {
        x: 504,
        y: 128,
        w: 64 * 4,
        h: 64,
        r: 255
      }.border
      
      args.outputs.primitives << {
        x: 508,
        y: 184,
        text: args.state.txt,
        size_enum: 16,
        r: 255
      }.label
      
      if aabb_input_rec
        if args.inputs.mouse.click
          play_click_sound args
          
          if i == 0
            args.state.txt.chop!
          elsif (i == charlist.length - 1)
            if args.state.txt == "2635"
              play_success_sound args
              args.state.scene = 1
              args.state.puzzles_done[3] = 1
              args.state.txt = ""
            end
          else
            if args.state.txt.length + 1 < 5
              args.state.txt += charlist[i]
            end
          end
        end
      end
    end
    
    gr = [
      [ 1, 2, 2, 3 ],
      [ 2, 3, 3, 1 ],
      [ 3, 3, 2, 2 ],
      [ 0, 1, 0, 2 ]
    ]
    
    gr.length.times.map do |i|
      gr[i].length.times.map do |j|
        args.outputs.primitives << {
          x: 440 + (j * 96),
          y: 240 + (i * 96),
          w: 96,
          h: 96,
          r: num_to_color(gr[i][j]).r,
          g: num_to_color(gr[i][j]).g,
          b: num_to_color(gr[i][j]).b,
          a: num_to_color(gr[i][j]).a
        }.solid
      end
    end
    
  elsif args.state.current_puzzle == 4
    sgrid = [
      [ 0, 0, 1, 2 ],
      [ 0, 0, 3, 0 ],
      [ 1, 0, 2, 3 ],
      [ 3, 2, 0, 0 ]
    ]
    
    vgrid = [
      [ 4, 3, 10, 10 ],
      [ 2, 1, 10, 4 ],
      [ 10, 4, 10, 10 ],
      [ 10, 10, 4, 1 ]
    ]
    
    args.state.sudogrid.length.times.map do |i|
      args.state.sudogrid[i].length.times.map do |j|
        if args.state.sudogrid[i][j] != 10
          aabb_sudoku_rec = AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, (498 + (j * 64)), (298 + (i * 64)).from_top, 64, 64)
          
          args.outputs.primitives << {
            x: (498 + (j * 64)),
            y: (298 + (i * 64)).from_top,
            w: 64,
            h: 64,
            r: 255,
            b: aabb_sudoku_rec ? 255 : 0
          }.border
          
          if args.state.sudogrid[i][j] != 0
            args.outputs.primitives << {
              x: (508 + (j * 64)),
              y: (236 + (i * 64)).from_top,
              text: args.state.sudogrid[i][j],
              size_enum: 16,
              r: 255,
              b: aabb_sudoku_rec ? 255 : 0
            }.label
          end
          
          if aabb_sudoku_rec
            if args.inputs.mouse.click
              play_click_sound args
              
              if args.state.sudogrid[i][j] + 1 > 4
                args.state.sudogrid[i][j] = 0
              else
                args.state.sudogrid[i][j] += 1
              end
            end
          end          
        end
      end
    end
    
    sgrid.length.times.map do |i|
      sgrid[i].length.times.map do |j|
        if sgrid[i][j] != 0
          args.outputs.primitives << {
            x: (498 + (j * 64)),
            y: (298 + (i * 64)).from_top,
            w: 64,
            h: 64,
            r: 255,
            b: 200
          }.border
          
          args.outputs.primitives << {
            x: (508 + (j * 64)),
            y: (234 + (i * 64)).from_top,
            text: sgrid[i][j],
            size_enum: 16,
            r: 255,
            b: 200
          }.label
        end
      end
    end
    
    res = 0
    args.state.sudogrid.length.times.map do |i|
      if arr_match(args.state.sudogrid[i], vgrid[i])
        res += 1
      end
    end
    
    if res == 4
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[4] = 1
    end
    
  elsif args.state.current_puzzle == 5
    magic = [
      [ 37, 78, 29, 70, 21, 62, 13, 54, 5 ],
      [ 6, 38, 79, 30, 71, 22, 63, 14, 46 ],
      [ 47, 7, 39, 80, 31, 72, 23, 55, 15 ],
      [ 16, 48, 8, 40, 81, 32, 64, 24, 56 ],
      [ 57, 17, 49, 9, 41, 73, 33, 64, 25 ],
      [ 26, 58, 18, 50, 1, 42, 74, 34, 66 ],
      [ 67, 27, 59, 10, 51, 2, 43, 75, 35 ],
      [ 36, 68, 19, 60, 11, 52, 3, 44, 76 ],
      [ 77, 28, 69, 20, 61, 12, 53, 4, 45 ],
    ]
  
    charlist = [ "<", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ">>" ]
    charlist.length.times.map do |i|
      aabb_input_rec = AABB(225 + (i * 72), 28, 64, 64, args.inputs.mouse.x, args.inputs.mouse.y, 1, 1)
      
      args.outputs.primitives << {
        x: 225 + (i * 72),
        y: 28,
        w: 64,
        h: 64,
        r: 255,
        b: aabb_input_rec ? 255 : 0
      }.border
      
      args.outputs.primitives << {
        x: 250 + (i * 72),
        y: 76,
        text: charlist[i],
        size_enum: 8,
        r: 255,
        b: aabb_input_rec ? 255 : 0
      }.label
      
      args.outputs.primitives << {
        x: 562,
        y: 118,
        w: 64 * 3,
        h: 64,
        r: 255
      }.border
      
      args.outputs.primitives << {
        x: 568,
        y: 174,
        text: args.state.txt,
        size_enum: 16,
        r: 255
      }.label
      
      if aabb_input_rec
        if args.inputs.mouse.click
          play_click_sound args
          
          if i == 0
            args.state.txt.chop!
          elsif (i == charlist.length - 1)
            if args.state.txt == "369"
              play_success_sound args
              args.state.scene = 1
              args.state.puzzles_done[5] = 1
              args.state.txt = ""
            end
          else
            if args.state.txt.length + 1 < 4
              args.state.txt += charlist[i]
            end
          end
        end
      end
    end
    
    magic.length.times.map do |i|
      magic[i].length.times.map do |j|
        args.outputs.primitives << {
          x: 442 + (j * 48),
          y: 200 + (i * 48),
          w: 48,
          h: 48,
          r: 255
        }.border
        
        args.outputs.primitives << {
          x: 458 + (j * 48),
          y: 240 + (i * 48),
          text: magic[i][j],
          size_enum: 1,
          r: 255
        }.label
      end
    end
    
  elsif args.state.current_puzzle == 6
    args.state.pyramid.length.times.map do |i|
      args.state.pyramid[i].length.times.map do |j|
        aabb_pyramid_rec = args.state.pyramid[i][j] < 10 && AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, (616 + (j * 64)) - (32 * args.state.pyramid[i].length), (216 + (i * 64)).from_top, 64, 64)
        
        args.outputs.primitives << {
          x: (632 + (j * 64)) - (32 * args.state.pyramid[i].length),
          y: (240 + (i * 64)).from_top,
          w: 64,
          h: 64,
          r: 255,
          b: aabb_pyramid_rec ? 255 : 0
        }.border
        
        if args.state.pyramid[i][j] != 0
          args.outputs.primitives << {
            x: (((i == 0 && j == 0) ? 637 : 655) + (j * 64)) - (32 * args.state.pyramid[i].length),
            y: (188 + (i * 64)).from_top,
            text: args.state.pyramid[i][j],
            size_enum: 8,
            r: 255,
            b: aabb_pyramid_rec ? 255 : 0
          }.label
        end
        
        if AABB(args.inputs.mouse.x, args.inputs.mouse.y, 1, 1, (616 + (j * 64)) - (32 * args.state.pyramid[i].length), (216 + (i * 64)).from_top, 64, 64)
          if args.state.pyramid[i][j] < 10
            if args.inputs.mouse.click
              play_click_sound args
              
              if args.state.pyramid[i][j] + 1 < 10
                args.state.pyramid[i][j] += 1
              else
                args.state.pyramid[i][j] = 0
              end
            end
          end
        end
      end
    end
    
    res1 = 0
    res2 = 0
    
    5.times.map do |i|
      if (args.state.pyramid[5][i] + args.state.pyramid[5][i + 1] == args.state.pyramid[4][i])
        res1 += 1
      end
    end
    
    4.times.map do |i|
      if (args.state.pyramid[4][i] + args.state.pyramid[4][i + 1] == args.state.pyramid[3][i])
        res2 += 1
      end
    end
    
    if res1 == 5 && res2 == 4
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[6] = 1
    end
    
  elsif args.state.current_puzzle == 7
    solution = [
      [ -1, -1, -1, 2 ],
      [ 4, 4, 2, 2    ],
      [ 1, -1, 5, 2   ],
      [ 1, 3, 3, 3    ]
    ]
    
    imgarr = [
      "sprites/Arrow_Up_Key_Light.png",
      "sprites/Arrow_Down_Key_Light.png",
      "sprites/Arrow_Left_Key_Light.png",
      "sprites/Arrow_Right_Key_Light.png",
      "sprites/Command_Key_Light.png"
    ]
    
    args.state.keys.length.times.map do |i|
      args.state.keys[i].length.times.map do |j|
        args.outputs.primitives << {
          x: 400 + (j * 128),
          y: (270 + (i * 128)).from_top,
          w: 128,
          h: 128,
          r: 255
        }.border
        
        if args.state.keys[i][j] == -1
          args.outputs.primitives << {
            x: 400 + (j * 128),
            y: (270 + (i * 128)).from_top,
            w: 128,
            h: 128,
            b: 200
          }.border
        elsif args.state.keys[i][j] >= 1 
          args.outputs.primitives << {
            x: 400 + (j * 128),
            y: (270 + (i * 128)).from_top,
            path: imgarr[args.state.keys[i][j] - 1],
            w: 128,
            h: 128
          }.sprite
        end
      end
    end
    
    args.outputs.primitives << {
      x: 410 + (args.state.trackkey.r * 128),
      y: (260 + (args.state.trackkey.c * 128)).from_top,
      w: 108,
      h: 108,
      r: 255,
      g: 255
    }.border
    
    if args.inputs.keyboard.key_down.up
      args.state.keys[args.state.track_keys[args.state.track_index].c][args.state.track_keys[args.state.track_index].r] = 1
    end
    if args.inputs.keyboard.key_down.down
      args.state.keys[args.state.track_keys[args.state.track_index].c][args.state.track_keys[args.state.track_index].r] = 2
    end
    if args.inputs.keyboard.key_down.left
      args.state.keys[args.state.track_keys[args.state.track_index].c][args.state.track_keys[args.state.track_index].r] = 3
    end
    if args.inputs.keyboard.key_down.right
      args.state.keys[args.state.track_keys[args.state.track_index].c][args.state.track_keys[args.state.track_index].r] = 4
    end
    
    if (args.inputs.keyboard.key_down.up || args.inputs.keyboard.key_down.down || args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_down.right)
      play_select_sound args
      
      if args.state.track_index + 1 > args.state.track_keys.length - 1
        args.state.track_index = 0
      else
        args.state.track_index += 1
      end
      
      args.state.trackkey = args.state.track_keys[args.state.track_index]
    end
    
    res = 0
    solution.length.times.map do |i|
      if arr_match(solution[i], args.state.keys[i])
        res += 1
      end
    end
    
    if res == 4
      play_success_sound args
      args.state.scene = 1
      args.state.puzzles_done[7] = 1
    end
  end
  
  if args.inputs.keyboard.key_down.escape
    play_back_sound args
    args.state.scene = 1
  end
end

def credits args
  args.outputs.background_color = [ 0, 0, 0, 255 ]
  
  args.outputs.primitives << {
    x: 522,
    y: 568,
    text: "CREATED BY",
    size_enum: 16,
    r: 255
  }.label
  
  args.outputs.primitives << {
    x: 496 + 28,
    y: 496,
    text: "RABIA ALHAFFAR",
    size_enum: 8,
    r: 255,
    g: 255
  }.label
  
  args.outputs.primitives << {
    x: 522,
    y: 368,
    text: "POWERED BY",
    size_enum: 16,
    r: 255
  }.label
  
  args.outputs.primitives << {
    x: 496 + 28 + 52,
    y: 196,
    w: 128,
    h: 128,
    path: "metadata/icon.png"
  }.sprite
  
  args.outputs.primitives << {
    x: 8,
    y: 32,
    text: "[ESCAPE]: BACK",
    size_enum: 2,
    r: 255
  }.label
  
  args.outputs.primitives << {
    x: args.state.player_x + args.state.board.x,
    y: args.state.player_y + args.state.board.y,
    w: 48,
    h: 48,
    r: 200,
    g: 0,
    b: 183,
  }.border
  
  args.outputs.primitives << args.state.board.border
  
  if args.inputs.keyboard.up
    if AABB(args.state.board.x, args.state.board.y, args.state.board.w - 48, args.state.board.h - 48, (args.state.board.x + args.state.player_x), (args.state.board.y + (args.state.player_y + 4)), 48, 48)
      args.state.player_y += 4
    end
  end
  if args.inputs.keyboard.down
    if AABB(args.state.board.x, args.state.board.y + 48, args.state.board.w - 48, args.state.board.h - 48, (args.state.board.x + args.state.player_x), (args.state.board.y + (args.state.player_y - 4)), 48, 48)
      args.state.player_y -= 4
    end
  end
  if args.inputs.keyboard.left
    if AABB(args.state.board.x + 48, args.state.board.y, args.state.board.w, args.state.board.h - 48, (args.state.board.x + (args.state.player_x - 4)), (args.state.board.y + args.state.player_y), 48, 48)
      args.state.player_x -= 4
    end
  end
  if args.inputs.keyboard.right
    if AABB(args.state.board.x - 48, args.state.board.y, args.state.board.w, args.state.board.h - 48, (args.state.board.x + (args.state.player_x + 4)), (args.state.board.y + args.state.player_y), 48, 48)
      args.state.player_x += 4
    end
  end
  
  if args.inputs.keyboard.key_down.escape
    args.state.scene = 0
  end
end
