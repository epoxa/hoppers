-- $Name: Лягушки-непоседы$

instead_version "1.9.1"

require "click"
require "timer"

main = room {
  nam = '',
  dsc = [[
    В этой игре лягушки прыгают друг через друга. Лягушка, которую перепрыгнули, выбывает из игры.
    На каждом ходу любая лягушка может прыгать через любую соседнюю, если за ней есть свободное место,
    однако, перепрыгивать царевну-лягушку нельзя.^
    Когда на болоте останется только царевна-лягушка, уровень пройден, и можно переходить к следующему.^
    Чтобы начать уровень сначала, нажмите на заголовок. Мы надеемся, что вам не придется делать это часто. Удачи!^^
  ]],
  obj = {
    vobj('start', '{Начать игру}'),
  },
  act = code [[ walk 'bog' ]],
}

bog = room {
  nam = 'Лягушки-непоседы',
  var {
    level = 1,
    state = '',
    phase = 'idle',
    curr = '',
    mid = '',
    dest = '',
  },
  disp = function(s) return 'Уровень ' .. s.level end,
  entered = function(s) s:restart_level() end,
  pic = function(s)
    local function frog() end

    local r, is_queen, l, last_leaf = 'bog.png', false;
    for l in s.state:gmatch('.') do
      if l == '^' then
        is_queen = true;
      else
        local leaf = leafs[l];
        local x, y = math.floor(leaf[1] * 68.8 + 0.5) + 44, leaf[2] * 68 + 30;
        if s.phase == 'select' and s.curr == l then
          r = r .. ';frog-gost.png@' .. x .. ',' .. y;
        else
          r = r .. ';frog.png@' .. x .. ',' .. y;
        end
        if is_queen then
          is_queen = false;
          r = r .. ';crown.png@' .. (x + 8) .. ',' .. (y - 14);
        end
      end
    end
    return r;
  end,
  click = function(s, x, y)
    local all, l = 'abcdefghijklm';
    for l in all:gmatch('.') do
      local leaf = leafs[l];
      local left, top = math.floor(leaf[1] * 68.8 + 0.5) + 44, leaf[2] * 68 + 30;
      if x > left and x < left + 50 and y > top and y < top + 60 then
        return s:do_click(l);
      end
    end
    set_sound('frog.ogg');
    s.phase = 'idle';
    return true;
  end,
  do_click = function(s, l)
    if s.phase == 'idle' then
      if s.state:find(l) then
        s.curr = l;
        s.phase = 'select';
        return true;
      end
    elseif s.phase == 'select' then
      local ways, w, i, mid, dest = leafs[s.curr][3];
      for i, w in pairs(ways) do
        dest = w:sub(2, 2);
        if dest == l then
          mid = w:sub(1, 1);
          if s.state:find(mid) and not s.state:find('%^' .. mid) and not s.state:find(dest) then
            -- Надо прыгать!
            set_sound('drop.ogg');
            local is_queen = s.state:find('%^' .. s.curr);
            s.state = s.state:gsub('%^' .. s.curr, ''):gsub(s.curr, ''):gsub(mid, '');
            if is_queen then
              s.state = s.state .. '^';
            end
            s.state = s.state .. dest;
            s.phase = 'idle';
            if s.state:len() == 2 then
              path('Дальше'):enable();
            end
            return true;
          else
            set_sound('frog.ogg');
            s.phase = 'idle'; -- Надо квакнуть
          end
        end
      end
      set_sound('frog.ogg');
      s.phase = 'idle';
      return true;
    end
  end,
  restart_level = function(s)
    s.state = maps[s.level];
    s.phase = 'idle';
  end,
  way = {
    vroom('Дальше', 'bog'):disable();
  },
  exit = function(s)
    s.level = s.level + 1;
    if s.level > #maps then
      s.level = 1;
    end
    path('Дальше'):disable();
  end,
}


leafs = {
  a = { 0, 0, { 'bc', 'dg', 'fk' } },
  b = { 2, 0, { 'df', 'gl', 'eh' } },
  c = { 4, 0, { 'ba', 'eg', 'hm' } },
  d = { 1, 1, { 'gj' } },
  e = { 3, 1, { 'gi' } },
  f = { 0, 2, { 'db', 'gh', 'il' } },
  g = { 2, 2, { 'da', 'ec', 'ik', 'jm' } },
  h = { 4, 2, { 'eb', 'gf', 'jl' } },
  i = { 1, 3, { 'ge' } },
  j = { 3, 3, { 'gd' } },
  k = { 0, 4, { 'fa', 'ig', 'lm' } },
  l = { 2, 4, { 'if', 'gb', 'jh' } },
  m = { 4, 4, { 'lk', 'jg', 'hc' } },
}

maps = {
  'adg^i',
  'acde^f',
  'adef^g',
  'afg^hi',
  '^aghil',
  '^abdfkl',
  'adf^ghi',
  'adef^gj',
  'ad^efhij',
  'a^bdfgim',
  'adei^jl',
  'abefhi^l',
  'abd^fikl',
  'abdfj^k',
  'adeghi^jl',
  'b^defghijl',
  'abdefghi^jl',
  'abdef^ij',
  'ab^defijl',
  'bd^efgijl',
  'adfg^ijlm',
  'abdefg^ijm',
  'abdefhi^lm',
  'acde^fgijkm',
  'abdefhi^jl',
  'abdefgi^j',
  'a^bdefhik',
  'adef^gijk',
  'abcdefi^jk',
  '^acdefjlm',
  'abde^fgjklm',
  'acdef^ghijk',
  'adef^gjlm',
  'adef^ghilm',
  'abdefgh^ijlm',
  'acdef^ghil',
  'abcdef^gijk',
  '^abdfghjkm',
  'abcdefhikl^m',
  'abcde^fgijklm',
}

iface.cmd = stead.hook(iface.cmd,
  function(f, s, inp, ...)
    if inp == 'look' then
      if here() == bog then
        bog:restart_level();
      end
    end
    return f(s, inp, ...);
  end);
