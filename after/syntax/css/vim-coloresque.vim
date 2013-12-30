" Name:         Coloresque
" Language:     color preview in vim
" Author:       Gorodinskii Konstantin <gor.konstantin@gmail.com>
" Licence:      Vim license
" Version:      0.9.5
" based on
" https://github.com/ap/vim-css-color
" https://github.com/lilydjwg/colorizer
" vim:et:ts=2 sw=2 sts=2

let s:hex={}
let b:matchescache = {}
let b:color_pattern = {}

let w:colorDictRegExp=''
for i in range(0, 255)
  let s:hex[ printf( '%02x', i ) ] = i
endfor

let s:black = '#000000'
let s:white = '#ffffff'

function! s:FGForBG(color)
  " pick suitable text color given a background color
  let color = tolower(a:color)
  let r = s:hex[color[0:1]]
  let g = s:hex[color[2:3]]
  let b = s:hex[color[4:5]]
  return r*30 + g*59 + b*11 > 12000 ? s:black : s:white
endfunction

let s:color_prefix  = 'gui'
let s:fg_color_calc = 'let color = "#" . toupper(a:color)'

function! s:RestoreColors()
    for part in keys(b:color_pattern)

      "if b:color_pattern[part]=="ffffff"
        "echoe part
      "endif

      call s:MatchColorValue(b:color_pattern[part], part)
      "echoe color
      "echoe b:color_pattern[color]
      "let group = 'cssColor' . tolower(strpart(b:color_pattern[part]["color"], 1))
      ""exe 'syn match' group '/'.escape(pattern, '/').'/ contained'
      "exe 'syn cluster cssColors add='.group
      "exe 'hi' group s:color_prefix.'bg='.b:color_pattern[part]["bg"] s:color_prefix.'fg='.b:color_pattern[part]["fg"]

      "if !exists('b:matchescache')
        "let b:matchescache={}
      "endif

      "let b:matchescache[part] = matchadd(group, part, -1)
    endfor
endfunction

function! s:MatchColorValue(color, part)
  if ! len(a:color) | return | endif

    let group = 'cssColor' . tolower(a:color)

  if !exists('b:color_pattern[a:part]')
    exe s:fg_color_calc
    exe 'syn cluster cssColors add='.group
    exe 'hi' group s:color_prefix.'bg='.color s:color_prefix.'fg='.s:FGForBG(a:color)
    let b:color_pattern[a:part] = a:color
  endif

  if !exists('b:matchescache')
    let b:matchescache = {}
  elseif !exists('b:matchescache[a:part]')
    let b:matchescache[a:part] = matchadd(group, a:part, -1)
  endif

  "call add(w:matchescache, matchadd(group, a:part, -1))

  return ''
endfunction

function! s:HexForRGBValue(r,g,b)
  " Convert 80% -> 204, 100% -> 255, etc.
  let rgb = map( [a:r,a:g,a:b], 'v:val =~ "%$" ? ( 255 * v:val ) / 100 : v:val' )
  return printf( '%02x%02x%02x', rgb[0], rgb[1], rgb[2] )
endfunction

function! s:HexForHSLValue(h,s,l)
  " Convert 80% -> 0.8, 100% -> 1.0, etc.
  let [s,l] = map( [a:s, a:l], 'v:val =~ "%$" ? v:val / 100.0 : str2float(v:val)' )
  " algorithm transcoded to vim from http://www.w3.org/TR/css3-color/#hsl-color
  let hh = ( a:h % 360 ) / 360.0
  let m2 = l <= 0.5 ? l * ( s + 1 ) : l + s - l * s
  let m1 = l * 2 - m2
  let rgb = []
  for h in [ hh + (1/3.0), hh, hh - (1/3.0) ]
    let h = h < 0 ? h + 1 : h > 1 ? h - 1 : h
    let v =
          \ h * 6 < 1 ? m1 + ( m2 - m1 ) * h * 6 :
          \ h * 2 < 1 ? m2 :
          \ h * 3 < 2 ? m1 + ( m2 - m1 ) * ( 2/3.0 - h ) * 6 :
          \ m1
    if v > 1.0 | return '' | endif
    let rgb += [ float2nr( 255 * v ) ]
  endfor
  return printf( '%02x%02x%02x', rgb[0], rgb[1], rgb[2] )
endfunction

function! s:ClearMatches()
  call clearmatches()

  if !exists('b:matchescache')
    return
  endif
  "for i in values(b:matchescache)
    "call matchdelete(i)
  "endfor
  unlet b:matchescache
endfunction

function! s:VimCssInit(update)

    if a:update==1
        call s:ClearMatches()
    endif
    :set isk+=-
    :set isk+=#
    :set isk+=.

    if len(keys(b:color_pattern))>0
        call s:RestoreColors()
        return
    endif

    "let b:matchescache = {}

    call s:AdditionalColors()

    "for i in range(1, line("$"))
        call s:PreviewCSSColor(join(getline(1,'$'), "\n"))
    "endfor

endfunction

function! s:AdditionalColors()
    "if exists('&b:colorDictRegExp')&&b:colorDictRegExp!=''
        "return
    "endif

  " w3c Colors
  " plus extra colors
    let w:colorDict = {
      \'aliceblue':             '#f0f8ff',
      \'antiquewhite':          '#faebd7',
      \'antiquewhite1':         '#ffefdb',
      \'antiquewhite2':         '#eedfcc',
      \'antiquewhite3':         '#cdc0b0',
      \'antiquewhite4':         '#8b8378',
      \'blanchedalmond':        '#ffebcd',
      \'blueviolet':            '#8a2be2',
      \'cadetblue':             '#5f9ea0',
      \'cadetblue1':            '#98f5ff',
      \'cadetblue2':            '#8ee5ee',
      \'cadetblue3':            '#7ac5cd',
      \'cadetblue4':            '#53868b',
      \'cornflowerblue':        '#6495ed',
      \'darkblue':              '#00008b',
      \'darkcyan':              '#008b8b',
      \'darkgoldenrod':         '#b8860b',
      \'darkgoldenrod1':        '#ffb90f',
      \'darkgoldenrod2':        '#eead0e',
      \'darkgoldenrod3':        '#cd950c',
      \'darkgoldenrod4':        '#8b6508',
      \'darkgray':              '#a9a9a9',
      \'darkgreen':             '#006400',
      \'darkgrey':              '#a9a9a9',
      \'darkkhaki':             '#bdb76b',
      \'darkmagenta':           '#8b008b',
      \'darkolivegreen':        '#556b2f',
      \'darkolivegreen1':       '#caff70',
      \'darkolivegreen2':       '#bcee68',
      \'darkolivegreen3':       '#a2cd5a',
      \'darkolivegreen4':       '#6e8b3d',
      \'darkorange':            '#ff8c00',
      \'darkorange1':           '#ff7f00',
      \'darkorange2':           '#ee7600',
      \'darkorange3':           '#cd6600',
      \'darkorange4':           '#8b4500',
      \'darkorchid':            '#9932cc',
      \'darkorchid1':           '#bf3eff',
      \'darkorchid2':           '#b23aee',
      \'darkorchid3':           '#9a32cd',
      \'darkorchid4':           '#68228b',
      \'darkred':               '#8b0000',
      \'darksalmon':            '#e9967a',
      \'darkseagreen':          '#8fbc8f',
      \'darkseagreen1':         '#c1ffc1',
      \'darkseagreen2':         '#b4eeb4',
      \'darkseagreen3':         '#9bcd9b',
      \'darkseagreen4':         '#698b69',
      \'darkslateblue':         '#483d8b',
      \'darkslategray':         '#2f4f4f',
      \'darkslategray1':        '#97ffff',
      \'darkslategray2':        '#8deeee',
      \'darkslategray3':        '#79cdcd',
      \'darkslategray4':        '#528b8b',
      \'darkslategrey':         '#2f4f4f',
      \'darkturquoise':         '#00ced1',
      \'darkviolet':            '#9400d3',
      \'deeppink':              '#ff1493',
      \'deeppink1':             '#ff1493',
      \'deeppink2':             '#ee1289',
      \'deeppink3':             '#cd1076',
      \'deeppink4':             '#8b0a50',
      \'deepskyblue':           '#00bfff',
      \'deepskyblue1':          '#00bfff',
      \'deepskyblue2':          '#00b2ee',
      \'deepskyblue3':          '#009acd',
      \'deepskyblue4':          '#00688b',
      \'dimgray':               '#696969',
      \'dimgrey':               '#696969',
      \'dodgerblue':            '#1e90ff',
      \'dodgerblue1':           '#1e90ff',
      \'dodgerblue2':           '#1c86ee',
      \'dodgerblue3':           '#1874cd',
      \'dodgerblue4':           '#104e8b',
      \'floralwhite':           '#fffaf0',
      \'forestgreen':           '#228b22',
      \'ghostwhite':            '#f8f8ff',
      \'greenyellow':           '#adff2f',
      \'hotpink':               '#ff69b4',
      \'hotpink1':              '#ff6eb4',
      \'hotpink2':              '#ee6aa7',
      \'hotpink3':              '#cd6090',
      \'hotpink4':              '#8b3a62',
      \'indianred':             '#cd5c5c',
      \'indianred1':            '#ff6a6a',
      \'indianred2':            '#ee6363',
      \'indianred3':            '#cd5555',
      \'indianred4':            '#8b3a3a',
      \'lavenderblush':         '#fff0f5',
      \'lavenderblush1':        '#fff0f5',
      \'lavenderblush2':        '#eee0e5',
      \'lavenderblush3':        '#cdc1c5',
      \'lavenderblush4':        '#8b8386',
      \'lawngreen':             '#7cfc00',
      \'lemonchiffon':          '#fffacd',
      \'lemonchiffon1':         '#fffacd',
      \'lemonchiffon2':         '#eee9bf',
      \'lemonchiffon3':         '#cdc9a5',
      \'lemonchiffon4':         '#8b8970',
      \'lightblue':             '#add8e6',
      \'lightblue1':            '#bfefff',
      \'lightblue2':            '#b2dfee',
      \'lightblue3':            '#9ac0cd',
      \'lightblue4':            '#68838b',
      \'lightcoral':            '#f08080',
      \'lightcyan':             '#e0ffff',
      \'lightcyan1':            '#e0ffff',
      \'lightcyan2':            '#d1eeee',
      \'lightcyan3':            '#b4cdcd',
      \'lightcyan4':            '#7a8b8b',
      \'lightgoldenrod':        '#eedd82',
      \'lightgoldenrod1':       '#ffec8b',
      \'lightgoldenrod2':       '#eedc82',
      \'lightgoldenrod3':       '#cdbe70',
      \'lightgoldenrod4':       '#8b814c',
      \'lightgoldenrodyellow':  '#fafad2',
      \'lightgray':             '#d3d3d3',
      \'lightgreen':            '#90ee90',
      \'lightgrey':             '#d3d3d3',
      \'lightpink':             '#ffb6c1',
      \'lightpink1':            '#ffaeb9',
      \'lightpink2':            '#eea2ad',
      \'lightpink3':            '#cd8c95',
      \'lightpink4':            '#8b5f65',
      \'lightsalmon':           '#ffa07a',
      \'lightsalmon1':          '#ffa07a',
      \'lightsalmon2':          '#ee9572',
      \'lightsalmon3':          '#cd8162',
      \'lightsalmon4':          '#8b5742',
      \'lightseagreen':         '#20b2aa',
      \'lightskyblue':          '#87cefa',
      \'lightskyblue1':         '#b0e2ff',
      \'lightskyblue2':         '#a4d3ee',
      \'lightskyblue3':         '#8db6cd',
      \'lightskyblue4':         '#607b8b',
      \'lightslateblue':        '#8470ff',
      \'lightslategray':        '#778899',
      \'lightslategrey':        '#778899',
      \'lightsteelblue':        '#b0c4de',
      \'lightsteelblue1':       '#cae1ff',
      \'lightsteelblue2':       '#bcd2ee',
      \'lightsteelblue3':       '#a2b5cd',
      \'lightsteelblue4':       '#6e7b8b',
      \'lightyellow':           '#ffffe0',
      \'lightyellow1':          '#ffffe0',
      \'lightyellow2':          '#eeeed1',
      \'lightyellow3':          '#cdcdb4',
      \'lightyellow4':          '#8b8b7a',
      \'limegreen':             '#32cd32',
      \'mediumaquamarine':      '#66cdaa',
      \'mediumblue':            '#0000cd',
      \'mediumorchid':          '#ba55d3',
      \'mediumorchid1':         '#e066ff',
      \'mediumorchid2':         '#d15fee',
      \'mediumorchid3':         '#b452cd',
      \'mediumorchid4':         '#7a378b',
      \'mediumpurple':          '#9370db',
      \'mediumpurple1':         '#ab82ff',
      \'mediumpurple2':         '#9f79ee',
      \'mediumpurple3':         '#8968cd',
      \'mediumpurple4':         '#5d478b',
      \'mediumseagreen':        '#3cb371',
      \'mediumslateblue':       '#7b68ee',
      \'mediumspringgreen':     '#00fa9a',
      \'mediumturquoise':       '#48d1cc',
      \'mediumvioletred':       '#c71585',
      \'midnightblue':          '#191970',
      \'mintcream':             '#f5fffa',
      \'mistyrose':             '#ffe4e1',
      \'mistyrose1':            '#ffe4e1',
      \'mistyrose2':            '#eed5d2',
      \'mistyrose3':            '#cdb7b5',
      \'mistyrose4':            '#8b7d7b',
      \'navajowhite':           '#ffdead',
      \'navajowhite1':          '#ffdead',
      \'navajowhite2':          '#eecfa1',
      \'navajowhite3':          '#cdb38b',
      \'navajowhite4':          '#8b795e',
      \'navyblue':              '#000080',
      \'oldlace':               '#fdf5e6',
      \'olivedrab':             '#6b8e23',
      \'olivedrab1':            '#c0ff3e',
      \'olivedrab2':            '#b3ee3a',
      \'olivedrab3':            '#9acd32',
      \'olivedrab4':            '#698b22',
      \'orangered':             '#ff4500',
      \'orangered1':            '#ff4500',
      \'orangered2':            '#ee4000',
      \'orangered3':            '#cd3700',
      \'orangered4':            '#8b2500',
      \'palegoldenrod':         '#eee8aa',
      \'palegreen':             '#98fb98',
      \'palegreen1':            '#9aff9a',
      \'palegreen2':            '#90ee90',
      \'palegreen3':            '#7ccd7c',
      \'palegreen4':            '#548b54',
      \'paleturquoise':         '#afeeee',
      \'paleturquoise1':        '#bbffff',
      \'paleturquoise2':        '#aeeeee',
      \'paleturquoise3':        '#96cdcd',
      \'paleturquoise4':        '#668b8b',
      \'palevioletred':         '#db7093',
      \'palevioletred1':        '#ff82ab',
      \'palevioletred2':        '#ee799f',
      \'palevioletred3':        '#cd6889',
      \'palevioletred4':        '#8b475d',
      \'papayawhip':            '#ffefd5',
      \'peachpuff':             '#ffdab9',
      \'peachpuff1':            '#ffdab9',
      \'peachpuff2':            '#eecbad',
      \'peachpuff3':            '#cdaf95',
      \'peachpuff4':            '#8b7765',
      \'powderblue':            '#b0e0e6',
      \'rosybrown':             '#bc8f8f',
      \'rosybrown1':            '#ffc1c1',
      \'rosybrown2':            '#eeb4b4',
      \'rosybrown3':            '#cd9b9b',
      \'rosybrown4':            '#8b6969',
      \'royalblue':             '#4169e1',
      \'royalblue1':            '#4876ff',
      \'royalblue2':            '#436eee',
      \'royalblue3':            '#3a5fcd',
      \'royalblue4':            '#27408b',
      \'saddlebrown':           '#8b4513',
      \'sandybrown':            '#f4a460',
      \'seagreen':              '#2e8b57',
      \'seagreen1':             '#54ff9f',
      \'seagreen2':             '#4eee94',
      \'seagreen3':             '#43cd80',
      \'seagreen4':             '#2e8b57',
      \'skyblue':               '#87ceeb',
      \'skyblue1':              '#87ceff',
      \'skyblue2':              '#7ec0ee',
      \'skyblue3':              '#6ca6cd',
      \'skyblue4':              '#4a708b',
      \'slateblue':             '#6a5acd',
      \'slateblue1':            '#836fff',
      \'slateblue2':            '#7a67ee',
      \'slateblue3':            '#6959cd',
      \'slateblue4':            '#473c8b',
      \'slategray':             '#708090',
      \'slategray1':            '#c6e2ff',
      \'slategray2':            '#b9d3ee',
      \'slategray3':            '#9fb6cd',
      \'slategray4':            '#6c7b8b',
      \'slategrey':             '#708090',
      \'springgreen':           '#00ff7f',
      \'springgreen1':          '#00ff7f',
      \'springgreen2':          '#00ee76',
      \'springgreen3':          '#00cd66',
      \'springgreen4':          '#008b45',
      \'steelblue':             '#4682b4',
      \'steelblue1':            '#63b8ff',
      \'steelblue2':            '#5cacee',
      \'steelblue3':            '#4f94cd',
      \'steelblue4':            '#36648b',
      \'violetred':             '#d02090',
      \'violetred1':            '#ff3e96',
      \'violetred2':            '#ee3a8c',
      \'violetred3':            '#cd3278',
      \'violetred4':            '#8b2252',
      \'whitesmoke':            '#f5f5f5',
      \'yellowgreen':           '#9acd32',
      \'alice blue':            '#f0f8ff',
      \'antique white':         '#faebd7',
      \'aquamarine':            '#7fffd4',
      \'aquamarine1':           '#7fffd4',
      \'aquamarine2':           '#76eec6',
      \'aquamarine3':           '#66cdaa',
      \'aquamarine4':           '#458b74',
      \'azure':                 '#f0ffff',
      \'azure1':                '#f0ffff',
      \'azure2':                '#e0eeee',
      \'azure3':                '#c1cdcd',
      \'azure4':                '#838b8b',
      \'beige':                 '#f5f5dc',
      \'bisque':                '#ffe4c4',
      \'bisque1':               '#ffe4c4',
      \'bisque2':               '#eed5b7',
      \'bisque3':               '#cdb79e',
      \'bisque4':               '#8b7d6b',
      \'black':                 '#000000',
      \'blanched almond':       '#ffebcd',
      \'blue':                  '#0000ff',
      \'blue violet':           '#8a2be2',
      \'blue1':                 '#0000ff',
      \'blue2':                 '#0000ee',
      \'blue3':                 '#0000cd',
      \'blue4':                 '#00008b',
      \'brown':                 '#a52a2a',
      \'brown1':                '#ff4040',
      \'brown2':                '#ee3b3b',
      \'brown3':                '#cd3333',
      \'brown4':                '#8b2323',
      \'burlywood':             '#deb887',
      \'burlywood1':            '#ffd39b',
      \'burlywood2':            '#eec591',
      \'burlywood3':            '#cdaa7d',
      \'burlywood4':            '#8b7355',
      \'cadet blue':            '#5f9ea0',
      \'chartreuse':            '#7fff00',
      \'chartreuse1':           '#7fff00',
      \'chartreuse2':           '#76ee00',
      \'chartreuse3':           '#66cd00',
      \'chartreuse4':           '#458b00',
      \'chocolate':             '#d2691e',
      \'chocolate1':            '#ff7f24',
      \'chocolate2':            '#ee7621',
      \'chocolate3':            '#cd661d',
      \'chocolate4':            '#8b4513',
      \'coral':                 '#ff7f50',
      \'coral1':                '#ff7256',
      \'coral2':                '#ee6a50',
      \'coral3':                '#cd5b45',
      \'coral4':                '#8b3e2f',
      \'cornflower blue':       '#6495ed',
      \'cornsilk':              '#fff8dc',
      \'cornsilk1':             '#fff8dc',
      \'cornsilk2':             '#eee8cd',
      \'cornsilk3':             '#cdc8b1',
      \'cornsilk4':             '#8b8878',
      \'cyan':                  '#00ffff',
      \'cyan1':                 '#00ffff',
      \'cyan2':                 '#00eeee',
      \'cyan3':                 '#00cdcd',
      \'cyan4':                 '#008b8b',
      \'dark blue':             '#00008b',
      \'dark cyan':             '#008b8b',
      \'dark goldenrod':        '#b8860b',
      \'dark gray':             '#a9a9a9',
      \'dark green':            '#006400',
      \'dark grey':             '#a9a9a9',
      \'dark khaki':            '#bdb76b',
      \'dark magenta':          '#8b008b',
      \'dark olive green':      '#556b2f',
      \'dark orange':           '#ff8c00',
      \'dark orchid':           '#9932cc',
      \'dark red':              '#8b0000',
      \'dark salmon':           '#e9967a',
      \'dark sea green':        '#8fbc8f',
      \'dark slate blue':       '#483d8b',
      \'dark slate gray':       '#2f4f4f',
      \'dark slate grey':       '#2f4f4f',
      \'dark turquoise':        '#00ced1',
      \'dark violet':           '#9400d3',
      \'deep pink':             '#ff1493',
      \'deep sky blue':         '#00bfff',
      \'dim gray':              '#696969',
      \'dim grey':              '#696969',
      \'dodger blue':           '#1e90ff',
      \'firebrick':             '#b22222',
      \'firebrick1':            '#ff3030',
      \'firebrick2':            '#ee2c2c',
      \'firebrick3':            '#cd2626',
      \'firebrick4':            '#8b1a1a',
      \'floral white':          '#fffaf0',
      \'forest green':          '#228b22',
      \'gainsboro':             '#dcdcdc',
      \'ghost white':           '#f8f8ff',
      \'gold':                  '#ffd700',
      \'gold1':                 '#ffd700',
      \'gold2':                 '#eec900',
      \'gold3':                 '#cdad00',
      \'gold4':                 '#8b7500',
      \'goldenrod':             '#daa520',
      \'goldenrod1':            '#ffc125',
      \'goldenrod2':            '#eeb422',
      \'goldenrod3':            '#cd9b1d',
      \'goldenrod4':            '#8b6914',
      \'gray':                  '#bebebe',
      \'gray0':                 '#000000',
      \'gray1':                 '#030303',
      \'gray10':                '#1a1a1a',
      \'gray100':               '#ffffff',
      \'gray11':                '#1c1c1c',
      \'gray12':                '#1f1f1f',
      \'gray13':                '#212121',
      \'gray14':                '#242424',
      \'gray15':                '#262626',
      \'gray16':                '#292929',
      \'gray17':                '#2b2b2b',
      \'gray18':                '#2e2e2e',
      \'gray19':                '#303030',
      \'gray2':                 '#050505',
      \'gray20':                '#333333',
      \'gray21':                '#363636',
      \'gray22':                '#383838',
      \'gray23':                '#3b3b3b',
      \'gray24':                '#3d3d3d',
      \'gray25':                '#404040',
      \'gray26':                '#424242',
      \'gray27':                '#454545',
      \'gray28':                '#474747',
      \'gray29':                '#4a4a4a',
      \'gray3':                 '#080808',
      \'gray30':                '#4d4d4d',
      \'gray31':                '#4f4f4f',
      \'gray32':                '#525252',
      \'gray33':                '#545454',
      \'gray34':                '#575757',
      \'gray35':                '#595959',
      \'gray36':                '#5c5c5c',
      \'gray37':                '#5e5e5e',
      \'gray38':                '#616161',
      \'gray39':                '#636363',
      \'gray4':                 '#0a0a0a',
      \'gray40':                '#666666',
      \'gray41':                '#696969',
      \'gray42':                '#6b6b6b',
      \'gray43':                '#6e6e6e',
      \'gray44':                '#707070',
      \'gray45':                '#737373',
      \'gray46':                '#757575',
      \'gray47':                '#787878',
      \'gray48':                '#7a7a7a',
      \'gray49':                '#7d7d7d',
      \'gray5':                 '#0d0d0d',
      \'gray50':                '#7f7f7f',
      \'gray51':                '#828282',
      \'gray52':                '#858585',
      \'gray53':                '#878787',
      \'gray54':                '#8a8a8a',
      \'gray55':                '#8c8c8c',
      \'gray56':                '#8f8f8f',
      \'gray57':                '#919191',
      \'gray58':                '#949494',
      \'gray59':                '#969696',
      \'gray6':                 '#0f0f0f',
      \'gray60':                '#999999',
      \'gray61':                '#9c9c9c',
      \'gray62':                '#9e9e9e',
      \'gray63':                '#a1a1a1',
      \'gray64':                '#a3a3a3',
      \'gray65':                '#a6a6a6',
      \'gray66':                '#a8a8a8',
      \'gray67':                '#ababab',
      \'gray68':                '#adadad',
      \'gray69':                '#b0b0b0',
      \'gray7':                 '#121212',
      \'gray70':                '#b3b3b3',
      \'gray71':                '#b5b5b5',
      \'gray72':                '#b8b8b8',
      \'gray73':                '#bababa',
      \'gray74':                '#bdbdbd',
      \'gray75':                '#bfbfbf',
      \'gray76':                '#c2c2c2',
      \'gray77':                '#c4c4c4',
      \'gray78':                '#c7c7c7',
      \'gray79':                '#c9c9c9',
      \'gray8':                 '#141414',
      \'gray80':                '#cccccc',
      \'gray81':                '#cfcfcf',
      \'gray82':                '#d1d1d1',
      \'gray83':                '#d4d4d4',
      \'gray84':                '#d6d6d6',
      \'gray85':                '#d9d9d9',
      \'gray86':                '#dbdbdb',
      \'gray87':                '#dedede',
      \'gray88':                '#e0e0e0',
      \'gray89':                '#e3e3e3',
      \'gray9':                 '#171717',
      \'gray90':                '#e5e5e5',
      \'gray91':                '#e8e8e8',
      \'gray92':                '#ebebeb',
      \'gray93':                '#ededed',
      \'gray94':                '#f0f0f0',
      \'gray95':                '#f2f2f2',
      \'gray96':                '#f5f5f5',
      \'gray97':                '#f7f7f7',
      \'gray98':                '#fafafa',
      \'gray99':                '#fcfcfc',
      \'green':                 '#00ff00',
      \'green yellow':          '#adff2f',
      \'green1':                '#00ff00',
      \'green2':                '#00ee00',
      \'green3':                '#00cd00',
      \'green4':                '#008b00',
      \'grey':                  '#bebebe',
      \'grey0':                 '#000000',
      \'grey1':                 '#030303',
      \'grey10':                '#1a1a1a',
      \'grey100':               '#ffffff',
      \'grey11':                '#1c1c1c',
      \'grey12':                '#1f1f1f',
      \'grey13':                '#212121',
      \'grey14':                '#242424',
      \'grey15':                '#262626',
      \'grey16':                '#292929',
      \'grey17':                '#2b2b2b',
      \'grey18':                '#2e2e2e',
      \'grey19':                '#303030',
      \'grey2':                 '#050505',
      \'grey20':                '#333333',
      \'grey21':                '#363636',
      \'grey22':                '#383838',
      \'grey23':                '#3b3b3b',
      \'grey24':                '#3d3d3d',
      \'grey25':                '#404040',
      \'grey26':                '#424242',
      \'grey27':                '#454545',
      \'grey28':                '#474747',
      \'grey29':                '#4a4a4a',
      \'grey3':                 '#080808',
      \'grey30':                '#4d4d4d',
      \'grey31':                '#4f4f4f',
      \'grey32':                '#525252',
      \'grey33':                '#545454',
      \'grey34':                '#575757',
      \'grey35':                '#595959',
      \'grey36':                '#5c5c5c',
      \'grey37':                '#5e5e5e',
      \'grey38':                '#616161',
      \'grey39':                '#636363',
      \'grey4':                 '#0a0a0a',
      \'grey40':                '#666666',
      \'grey41':                '#696969',
      \'grey42':                '#6b6b6b',
      \'grey43':                '#6e6e6e',
      \'grey44':                '#707070',
      \'grey45':                '#737373',
      \'grey46':                '#757575',
      \'grey47':                '#787878',
      \'grey48':                '#7a7a7a',
      \'grey49':                '#7d7d7d',
      \'grey5':                 '#0d0d0d',
      \'grey50':                '#7f7f7f',
      \'grey51':                '#828282',
      \'grey52':                '#858585',
      \'grey53':                '#878787',
      \'grey54':                '#8a8a8a',
      \'grey55':                '#8c8c8c',
      \'grey56':                '#8f8f8f',
      \'grey57':                '#919191',
      \'grey58':                '#949494',
      \'grey59':                '#969696',
      \'grey6':                 '#0f0f0f',
      \'grey60':                '#999999',
      \'grey61':                '#9c9c9c',
      \'grey62':                '#9e9e9e',
      \'grey63':                '#a1a1a1',
      \'grey64':                '#a3a3a3',
      \'grey65':                '#a6a6a6',
      \'grey66':                '#a8a8a8',
      \'grey67':                '#ababab',
      \'grey68':                '#adadad',
      \'grey69':                '#b0b0b0',
      \'grey7':                 '#121212',
      \'grey70':                '#b3b3b3',
      \'grey71':                '#b5b5b5',
      \'grey72':                '#b8b8b8',
      \'grey73':                '#bababa',
      \'grey74':                '#bdbdbd',
      \'grey75':                '#bfbfbf',
      \'grey76':                '#c2c2c2',
      \'grey77':                '#c4c4c4',
      \'grey78':                '#c7c7c7',
      \'grey79':                '#c9c9c9',
      \'grey8':                 '#141414',
      \'grey80':                '#cccccc',
      \'grey81':                '#cfcfcf',
      \'grey82':                '#d1d1d1',
      \'grey83':                '#d4d4d4',
      \'grey84':                '#d6d6d6',
      \'grey85':                '#d9d9d9',
      \'grey86':                '#dbdbdb',
      \'grey87':                '#dedede',
      \'grey88':                '#e0e0e0',
      \'grey89':                '#e3e3e3',
      \'grey9':                 '#171717',
      \'grey90':                '#e5e5e5',
      \'grey91':                '#e8e8e8',
      \'grey92':                '#ebebeb',
      \'grey93':                '#ededed',
      \'grey94':                '#f0f0f0',
      \'grey95':                '#f2f2f2',
      \'grey96':                '#f5f5f5',
      \'grey97':                '#f7f7f7',
      \'grey98':                '#fafafa',
      \'grey99':                '#fcfcfc',
      \'honeydew':              '#f0fff0',
      \'honeydew1':             '#f0fff0',
      \'honeydew2':             '#e0eee0',
      \'honeydew3':             '#c1cdc1',
      \'honeydew4':             '#838b83',
      \'hot pink':              '#ff69b4',
      \'indian red':            '#cd5c5c',
      \'ivory':                 '#fffff0',
      \'ivory1':                '#fffff0',
      \'ivory2':                '#eeeee0',
      \'ivory3':                '#cdcdc1',
      \'ivory4':                '#8b8b83',
      \'khaki':                 '#f0e68c',
      \'khaki1':                '#fff68f',
      \'khaki2':                '#eee685',
      \'khaki3':                '#cdc673',
      \'khaki4':                '#8b864e',
      \'lavender':              '#e6e6fa',
      \'lavender blush':        '#fff0f5',
      \'lawn green':            '#7cfc00',
      \'lemon chiffon':         '#fffacd',
      \'light blue':            '#add8e6',
      \'light coral':           '#f08080',
      \'light cyan':            '#e0ffff',
      \'light goldenrod':       '#eedd82',
      \'light goldenrod yellow':'#fafad2',
      \'light gray':            '#d3d3d3',
      \'light green':           '#90ee90',
      \'light grey':            '#d3d3d3',
      \'light pink':            '#ffb6c1',
      \'light salmon':          '#ffa07a',
      \'light sea green':       '#20b2aa',
      \'light sky blue':        '#87cefa',
      \'light slate blue':      '#8470ff',
      \'light slate gray':      '#778899',
      \'light slate grey':      '#778899',
      \'light steel blue':      '#b0c4de',
      \'light yellow':          '#ffffe0',
      \'lime green':            '#32cd32',
      \'linen':                 '#faf0e6',
      \'magenta':               '#ff00ff',
      \'magenta1':              '#ff00ff',
      \'magenta2':              '#ee00ee',
      \'magenta3':              '#cd00cd',
      \'magenta4':              '#8b008b',
      \'maroon':                '#b03060',
      \'maroon1':               '#ff34b3',
      \'maroon2':               '#ee30a7',
      \'maroon3':               '#cd2990',
      \'maroon4':               '#8b1c62',
      \'medium aquamarine':     '#66cdaa',
      \'medium blue':           '#0000cd',
      \'medium orchid':         '#ba55d3',
      \'medium purple':         '#9370db',
      \'medium sea green':      '#3cb371',
      \'medium slate blue':     '#7b68ee',
      \'medium spring green':   '#00fa9a',
      \'medium turquoise':      '#48d1cc',
      \'medium violet red':     '#c71585',
      \'midnight blue':         '#191970',
      \'mint cream':            '#f5fffa',
      \'misty rose':            '#ffe4e1',
      \'moccasin':              '#ffe4b5',
      \'navajo white':          '#ffdead',
      \'navy':                  '#000080',
      \'navy blue':             '#000080',
      \'old lace':              '#fdf5e6',
      \'olive drab':            '#6b8e23',
      \'orange':                '#ffa500',
      \'orange red':            '#ff4500',
      \'orange1':               '#ffa500',
      \'orange2':               '#ee9a00',
      \'orange3':               '#cd8500',
      \'orange4':               '#8b5a00',
      \'orchid':                '#da70d6',
      \'orchid1':               '#ff83fa',
      \'orchid2':               '#ee7ae9',
      \'orchid3':               '#cd69c9',
      \'orchid4':               '#8b4789',
      \'pale goldenrod':        '#eee8aa',
      \'pale green':            '#98fb98',
      \'pale turquoise':        '#afeeee',
      \'pale violet red':       '#db7093',
      \'papaya whip':           '#ffefd5',
      \'peach puff':            '#ffdab9',
      \'peru':                  '#cd853f',
      \'pink':                  '#ffc0cb',
      \'pink1':                 '#ffb5c5',
      \'pink2':                 '#eea9b8',
      \'pink3':                 '#cd919e',
      \'pink4':                 '#8b636c',
      \'plum':                  '#dda0dd',
      \'plum1':                 '#ffbbff',
      \'plum2':                 '#eeaeee',
      \'plum3':                 '#cd96cd',
      \'plum4':                 '#8b668b',
      \'powder blue':           '#b0e0e6',
      \'purple':                '#a020f0',
      \'purple1':               '#9b30ff',
      \'purple2':               '#912cee',
      \'purple3':               '#7d26cd',
      \'purple4':               '#551a8b',
      \'red':                   '#ff0000',
      \'red1':                  '#ff0000',
      \'red2':                  '#ee0000',
      \'red3':                  '#cd0000',
      \'red4':                  '#8b0000',
      \'rosy brown':            '#bc8f8f',
      \'royal blue':            '#4169e1',
      \'saddle brown':          '#8b4513',
      \'salmon':                '#fa8072',
      \'salmon1':               '#ff8c69',
      \'salmon2':               '#ee8262',
      \'salmon3':               '#cd7054',
      \'salmon4':               '#8b4c39',
      \'sandy brown':           '#f4a460',
      \'sea green':             '#2e8b57',
      \'seashell':              '#fff5ee',
      \'seashell1':             '#fff5ee',
      \'seashell2':             '#eee5de',
      \'seashell3':             '#cdc5bf',
      \'seashell4':             '#8b8682',
      \'sienna':                '#a0522d',
      \'sienna1':               '#ff8247',
      \'sienna2':               '#ee7942',
      \'sienna3':               '#cd6839',
      \'sienna4':               '#8b4726',
      \'sky blue':              '#87ceeb',
      \'slate blue':            '#6a5acd',
      \'slate gray':            '#708090',
      \'slate grey':            '#708090',
      \'snow':                  '#fffafa',
      \'snow1':                 '#fffafa',
      \'snow2':                 '#eee9e9',
      \'snow3':                 '#cdc9c9',
      \'snow4':                 '#8b8989',
      \'spring green':          '#00ff7f',
      \'steel blue':            '#4682b4',
      \'tan':                   '#d2b48c',
      \'tan1':                  '#ffa54f',
      \'tan2':                  '#ee9a49',
      \'tan3':                  '#cd853f',
      \'tan4':                  '#8b5a2b',
      \'thistle':               '#d8bfd8',
      \'thistle1':              '#ffe1ff',
      \'thistle2':              '#eed2ee',
      \'thistle3':              '#cdb5cd',
      \'thistle4':              '#8b7b8b',
      \'tomato':                '#ff6347',
      \'tomato1':               '#ff6347',
      \'tomato2':               '#ee5c42',
      \'tomato3':               '#cd4f39',
      \'tomato4':               '#8b3626',
      \'turquoise':             '#40e0d0',
      \'turquoise1':            '#00f5ff',
      \'turquoise2':            '#00e5ee',
      \'turquoise3':            '#00c5cd',
      \'turquoise4':            '#00868b',
      \'violet':                '#ee82ee',
      \'violet red':            '#d02090',
      \'wheat':                 '#f5deb3',
      \'wheat1':                '#ffe7ba',
      \'wheat2':                '#eed8ae',
      \'wheat3':                '#cdba96',
      \'wheat4':                '#8b7e66',
      \'white':                 '#ffffff',
      \'white smoke':           '#f5f5f5',
      \'yellow':                '#ffff00',
      \'yellow green':          '#9acd32',
      \'yellow1':               '#ffff00',
      \'yellow2':               '#eeee00',
      \'yellow3':               '#cdcd00',
      \'yellow4':               '#8b8b00',
    \}

  "let w:colorDictRegExp = '\('
  for _color in keys(w:colorDict)
    "let w:colorDictRegExp.='\<'._color.'\>\|'
    call s:MatchColorValue(strpart(w:colorDict[tolower(_color)], 1), '\<\c'._color.'\>')
  endfor
  "let w:colorDictRegExp=strpart(w:colorDictRegExp, 0, len(w:colorDictRegExp)-2).'\)\c'
endfunction

function! s:ProcessByLine(w)
  call s:PreviewCSSColor(getline(a:w))
endfunction

function! s:PreviewCSSColor(str)
  "if !exists('&w:colorDictRegExp')
  "endif

  let line=a:str "getline(a:w)
  let colorexps = {
    \ 'hex'  : '#[0-9A-Fa-f]\{3\}\>\|#[0-9A-Fa-f]\{6\}\>',
    \ 'rgba' : 'rgba\?(\s*\(\d\{1,3}%\?\)\s*,\s*\(\d\{1,3}%\?\)\s*,\s*\(\d\{1,3}%\?\)\s*\%(,[^)]*\)\?)',
    \ 'hsla' : 'hsla\?(\s*\(\d\{1,3}%\?\)\s*,\s*\(\d\{1,3}%\?\)\s*,\s*\(\d\{1,3}%\?\)\s*\%(,[^)]*\)\?)'
    \ }
    "\ 'color': w:colorDictRegExp

  "let foundcolor=''

  for exp in keys(colorexps)
      let place=0

      if exists("foundcolor")
          unlet foundcolor
      endif

      while 1
          if exp=='rgba'||exp=='hsla'
              let foundcolor = matchlist(a:str, colorexps[exp], place)
          else
              let foundcolor = matchstr(a:str, colorexps[exp], place)
          endif

          let place = matchend(a:str, colorexps[exp], place)

          if empty(foundcolor)
              break
          endif

          if exp=='hex'
              let part = foundcolor.'\>'
          else
              let part = foundcolor[0]
          endif

          if exp=='hex'
              if len(foundcolor) == 4
                  let foundcolor = substitute(foundcolor, '[[:xdigit:]]', '&&', 'g')
              endif
              call s:MatchColorValue(strpart(foundcolor, 1), part)
          elseif exp=='rgba'
              "TODO get rid of duplicated variables
              call s:MatchColorValue(s:HexForRGBValue(foundcolor[1], foundcolor[2], foundcolor[3]), part)
          elseif exp=='hsla'
              call s:MatchColorValue(s:HexForHSLValue(foundcolor[1], foundcolor[2], foundcolor[3]), part)
          endif
      endwhile
  endfor

endfunction

if has("gui_running") || &t_Co==256
  " HACK modify cssDefinition to add @cssColors to its contains
  redir => cssdef
  silent! syn list cssDefinition
  redir END
  if len( cssdef )
    for out in split( cssdef, "\n" )
      if out !~ '^cssDefinition ' | continue | endif
      let out = substitute( out, ' \+xxx \+', ' ', '' )
      let out = substitute( out, ' contains=\zs', '@cssColors,', '' )
      exe 'syn region' out
    endfor
  endif

  if ! has('gui_running')

    let s:black = 0
    let s:white = 15

    let s:color_prefix  = 'cterm'
    let s:fg_color_calc = 'let color = s:XTermColorForRGB(a:color)'

    " preset 16 vt100 colors
    let s:xtermcolor = [
      \ [ 0x00, 0x00, 0x00,  0 ],
      \ [ 0xCD, 0x00, 0x00,  1 ],
      \ [ 0x00, 0xCD, 0x00,  2 ],
      \ [ 0xCD, 0xCD, 0x00,  3 ],
      \ [ 0x00, 0x00, 0xEE,  4 ],
      \ [ 0xCD, 0x00, 0xCD,  5 ],
      \ [ 0x00, 0xCD, 0xCD,  6 ],
      \ [ 0xE5, 0xE5, 0xE5,  7 ],
      \ [ 0x7F, 0x7F, 0x7F,  8 ],
      \ [ 0xFF, 0x00, 0x00,  9 ],
      \ [ 0x00, 0xFF, 0x00, 10 ],
      \ [ 0xFF, 0xFF, 0x00, 11 ],
      \ [ 0x5C, 0x5C, 0xFF, 12 ],
      \ [ 0xFF, 0x00, 0xFF, 13 ],
      \ [ 0x00, 0xFF, 0xFF, 14 ],
      \ [ 0xFF, 0xFF, 0xFF, 15 ]]
    " grayscale ramp
    " (value is 8+10*lum for lum in 0..23)
    let s:xtermcolor += [
      \ [ 0x08, 0x08, 0x08, 232 ],
      \ [ 0x12, 0x12, 0x12, 233 ],
      \ [ 0x1C, 0x1C, 0x1C, 234 ],
      \ [ 0x26, 0x26, 0x26, 235 ],
      \ [ 0x30, 0x30, 0x30, 236 ],
      \ [ 0x3A, 0x3A, 0x3A, 237 ],
      \ [ 0x44, 0x44, 0x44, 238 ],
      \ [ 0x4E, 0x4E, 0x4E, 239 ],
      \ [ 0x58, 0x58, 0x58, 240 ],
      \ [ 0x62, 0x62, 0x62, 241 ],
      \ [ 0x6C, 0x6C, 0x6C, 242 ],
      \ [ 0x76, 0x76, 0x76, 243 ],
      \ [ 0x80, 0x80, 0x80, 244 ],
      \ [ 0x8A, 0x8A, 0x8A, 245 ],
      \ [ 0x94, 0x94, 0x94, 246 ],
      \ [ 0x9E, 0x9E, 0x9E, 247 ],
      \ [ 0xA8, 0xA8, 0xA8, 248 ],
      \ [ 0xB2, 0xB2, 0xB2, 249 ],
      \ [ 0xBC, 0xBC, 0xBC, 250 ],
      \ [ 0xC6, 0xC6, 0xC6, 251 ],
      \ [ 0xD0, 0xD0, 0xD0, 252 ],
      \ [ 0xDA, 0xDA, 0xDA, 253 ],
      \ [ 0xE4, 0xE4, 0xE4, 254 ],
      \ [ 0xEE, 0xEE, 0xEE, 255 ]]

    " the 6 values used in the xterm color cube
    "                    0    95   135   175   215   255
    let s:cubergb = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]

    " 0..255 mapped to 0..5 based on the color cube values
    let s:xvquant = repeat([0],48)
        \         + repeat([1],68)
        \         + repeat([2],40)
        \         + repeat([3],40)
        \         + repeat([4],40)
        \         + repeat([5],20)
    " tweak the mapping for the exact matches (0 and 1 already correct)
    let s:xvquant[s:cubergb[2]] = 2
    let s:xvquant[s:cubergb[3]] = 3
    let s:xvquant[s:cubergb[4]] = 4
    let s:xvquant[s:cubergb[5]] = 5

    " selects the nearest xterm color for a rgb value like #FF0000
    function! s:XTermColorForRGB(color)
      let best_match=0
      let smallest_distance = 10000000000
      let color = tolower(a:color)
      let r = s:hex[color[0:1]]
      let g = s:hex[color[2:3]]
      let b = s:hex[color[4:5]]

      let vr = s:xvquant[r]
      let vg = s:xvquant[g]
      let vb = s:xvquant[b]
      let cidx = vr * 36 + vg * 6 + vb + 16
      let ccol = [ s:cubergb[vr], s:cubergb[vg], s:cubergb[vb], cidx ]

      for [tr,tg,tb,idx] in [ ccol ] + s:xtermcolor
        let dr = tr - r
        let dg = tg - g
        let db = tb - b
        let distance = dr*dr + dg*dg + db*db
        if distance == 0 | return idx | endif
        if distance > smallest_distance | continue | endif
        let smallest_distance = distance
        let best_match = idx
      endfor
      return best_match
    endfunction
  endif

  hi cssColor000000 guibg=#000000 guifg=#FFFFFF ctermbg=16  ctermfg=231 | syn cluster cssColors add=cssColor000000
  hi cssColor000080 guibg=#000080 guifg=#FFFFFF ctermbg=235 ctermfg=231 | syn cluster cssColors add=cssColor000080
  hi cssColor00008b guibg=#00008B guifg=#FFFFFF ctermbg=4   ctermfg=231 | syn cluster cssColors add=cssColor00008b
  hi cssColor0000cd guibg=#0000CD guifg=#FFFFFF ctermbg=4   ctermfg=231 | syn cluster cssColors add=cssColor0000cd
  hi cssColor0000ff guibg=#0000FF guifg=#FFFFFF ctermbg=4   ctermfg=231 | syn cluster cssColors add=cssColor0000ff
  hi cssColor006400 guibg=#006400 guifg=#FFFFFF ctermbg=235 ctermfg=231 | syn cluster cssColors add=cssColor006400
  hi cssColor008000 guibg=#008000 guifg=#FFFFFF ctermbg=2   ctermfg=231 | syn cluster cssColors add=cssColor008000
  hi cssColor008080 guibg=#008080 guifg=#FFFFFF ctermbg=30  ctermfg=231 | syn cluster cssColors add=cssColor008080
  hi cssColor008b8b guibg=#008B8B guifg=#FFFFFF ctermbg=30  ctermfg=231 | syn cluster cssColors add=cssColor008b8b
  hi cssColor00bfff guibg=#00BFFF guifg=#000000 ctermbg=6   ctermfg=16  | syn cluster cssColors add=cssColor00bfff
  hi cssColor00ced1 guibg=#00CED1 guifg=#000000 ctermbg=6   ctermfg=16  | syn cluster cssColors add=cssColor00ced1
  hi cssColor00fa9a guibg=#00FA9A guifg=#000000 ctermbg=6   ctermfg=16  | syn cluster cssColors add=cssColor00fa9a
  hi cssColor00ff00 guibg=#00FF00 guifg=#000000 ctermbg=10  ctermfg=16  | syn cluster cssColors add=cssColor00ff00
  hi cssColor00ff7f guibg=#00FF7F guifg=#000000 ctermbg=6   ctermfg=16  | syn cluster cssColors add=cssColor00ff7f
  hi cssColor00ffff guibg=#00FFFF guifg=#000000 ctermbg=51  ctermfg=16  | syn cluster cssColors add=cssColor00ffff
  hi cssColor191970 guibg=#191970 guifg=#FFFFFF ctermbg=237 ctermfg=231 | syn cluster cssColors add=cssColor191970
  hi cssColor1e90ff guibg=#1E90FF guifg=#000000 ctermbg=12  ctermfg=16  | syn cluster cssColors add=cssColor1e90ff
  hi cssColor20b2aa guibg=#20B2AA guifg=#000000 ctermbg=37  ctermfg=16  | syn cluster cssColors add=cssColor20b2aa
  hi cssColor228b22 guibg=#228B22 guifg=#FFFFFF ctermbg=2   ctermfg=231 | syn cluster cssColors add=cssColor228b22
  hi cssColor2e8b57 guibg=#2E8B57 guifg=#FFFFFF ctermbg=240 ctermfg=231 | syn cluster cssColors add=cssColor2e8b57
  hi cssColor2f4f4f guibg=#2F4F4F guifg=#FFFFFF ctermbg=238 ctermfg=231 | syn cluster cssColors add=cssColor2f4f4f
  hi cssColor32cd32 guibg=#32CD32 guifg=#000000 ctermbg=2   ctermfg=16  | syn cluster cssColors add=cssColor32cd32
  hi cssColor3cb371 guibg=#3CB371 guifg=#000000 ctermbg=71  ctermfg=16  | syn cluster cssColors add=cssColor3cb371
  hi cssColor40e0d0 guibg=#40E0D0 guifg=#000000 ctermbg=80  ctermfg=16  | syn cluster cssColors add=cssColor40e0d0
  hi cssColor4169e1 guibg=#4169E1 guifg=#FFFFFF ctermbg=12  ctermfg=231 | syn cluster cssColors add=cssColor4169e1
  hi cssColor4682b4 guibg=#4682B4 guifg=#FFFFFF ctermbg=67  ctermfg=231 | syn cluster cssColors add=cssColor4682b4
  hi cssColor483d8b guibg=#483D8B guifg=#FFFFFF ctermbg=240 ctermfg=231 | syn cluster cssColors add=cssColor483d8b
  hi cssColor48d1cc guibg=#48D1CC guifg=#000000 ctermbg=80  ctermfg=16  | syn cluster cssColors add=cssColor48d1cc
  hi cssColor4b0082 guibg=#4B0082 guifg=#FFFFFF ctermbg=238 ctermfg=231 | syn cluster cssColors add=cssColor4b0082
  hi cssColor556b2f guibg=#556B2F guifg=#FFFFFF ctermbg=239 ctermfg=231 | syn cluster cssColors add=cssColor556b2f
  hi cssColor5f9ea0 guibg=#5F9EA0 guifg=#000000 ctermbg=73  ctermfg=16  | syn cluster cssColors add=cssColor5f9ea0
  hi cssColor6495ed guibg=#6495ED guifg=#000000 ctermbg=12  ctermfg=16  | syn cluster cssColors add=cssColor6495ed
  hi cssColor66cdaa guibg=#66CDAA guifg=#000000 ctermbg=79  ctermfg=16  | syn cluster cssColors add=cssColor66cdaa
  hi cssColor696969 guibg=#696969 guifg=#FFFFFF ctermbg=242 ctermfg=231 | syn cluster cssColors add=cssColor696969
  hi cssColor6a5acd guibg=#6A5ACD guifg=#FFFFFF ctermbg=12  ctermfg=231 | syn cluster cssColors add=cssColor6a5acd
  hi cssColor6b8e23 guibg=#6B8E23 guifg=#FFFFFF ctermbg=241 ctermfg=231 | syn cluster cssColors add=cssColor6b8e23
  hi cssColor708090 guibg=#708090 guifg=#000000 ctermbg=66  ctermfg=16  | syn cluster cssColors add=cssColor708090
  hi cssColor778899 guibg=#778899 guifg=#000000 ctermbg=102 ctermfg=16  | syn cluster cssColors add=cssColor778899
  hi cssColor7b68ee guibg=#7B68EE guifg=#000000 ctermbg=12  ctermfg=16  | syn cluster cssColors add=cssColor7b68ee
  hi cssColor7cfc00 guibg=#7CFC00 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColor7cfc00
  hi cssColor7fff00 guibg=#7FFF00 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColor7fff00
  hi cssColor7fffd4 guibg=#7FFFD4 guifg=#000000 ctermbg=122 ctermfg=16  | syn cluster cssColors add=cssColor7fffd4
  hi cssColor800000 guibg=#800000 guifg=#FFFFFF ctermbg=88  ctermfg=231 | syn cluster cssColors add=cssColor800000
  hi cssColor800080 guibg=#800080 guifg=#FFFFFF ctermbg=240 ctermfg=231 | syn cluster cssColors add=cssColor800080
  hi cssColor808000 guibg=#808000 guifg=#FFFFFF ctermbg=240 ctermfg=231 | syn cluster cssColors add=cssColor808000
  hi cssColor808080 guibg=#808080 guifg=#000000 ctermbg=244 ctermfg=16  | syn cluster cssColors add=cssColor808080
  hi cssColor87ceeb guibg=#87CEEB guifg=#000000 ctermbg=117 ctermfg=16  | syn cluster cssColors add=cssColor87ceeb
  hi cssColor87cefa guibg=#87CEFA guifg=#000000 ctermbg=117 ctermfg=16  | syn cluster cssColors add=cssColor87cefa
  hi cssColor8a2be2 guibg=#8A2BE2 guifg=#FFFFFF ctermbg=12  ctermfg=231 | syn cluster cssColors add=cssColor8a2be2
  hi cssColor8b0000 guibg=#8B0000 guifg=#FFFFFF ctermbg=88  ctermfg=231 | syn cluster cssColors add=cssColor8b0000
  hi cssColor8b008b guibg=#8B008B guifg=#FFFFFF ctermbg=5   ctermfg=231 | syn cluster cssColors add=cssColor8b008b
  hi cssColor8b4513 guibg=#8B4513 guifg=#FFFFFF ctermbg=94  ctermfg=231 | syn cluster cssColors add=cssColor8b4513
  hi cssColor8fbc8f guibg=#8FBC8F guifg=#000000 ctermbg=108 ctermfg=16  | syn cluster cssColors add=cssColor8fbc8f
  hi cssColor90ee90 guibg=#90EE90 guifg=#000000 ctermbg=249 ctermfg=16  | syn cluster cssColors add=cssColor90ee90
  hi cssColor9370d8 guibg=#9370D8 guifg=#000000 ctermbg=12  ctermfg=16  | syn cluster cssColors add=cssColor9370d8
  hi cssColor9400d3 guibg=#9400D3 guifg=#FFFFFF ctermbg=5   ctermfg=231 | syn cluster cssColors add=cssColor9400d3
  hi cssColor98fb98 guibg=#98FB98 guifg=#000000 ctermbg=250 ctermfg=16  | syn cluster cssColors add=cssColor98fb98
  hi cssColor9932cc guibg=#9932CC guifg=#FFFFFF ctermbg=5   ctermfg=231 | syn cluster cssColors add=cssColor9932cc
  hi cssColor9acd32 guibg=#9ACD32 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColor9acd32
  hi cssColora0522d guibg=#A0522D guifg=#FFFFFF ctermbg=130 ctermfg=231 | syn cluster cssColors add=cssColora0522d
  hi cssColora52a2a guibg=#A52A2A guifg=#FFFFFF ctermbg=124 ctermfg=231 | syn cluster cssColors add=cssColora52a2a
  hi cssColora9a9a9 guibg=#A9A9A9 guifg=#000000 ctermbg=248 ctermfg=16  | syn cluster cssColors add=cssColora9a9a9
  hi cssColoradd8e6 guibg=#ADD8E6 guifg=#000000 ctermbg=152 ctermfg=16  | syn cluster cssColors add=cssColoradd8e6
  hi cssColoradff2f guibg=#ADFF2F guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColoradff2f
  hi cssColorafeeee guibg=#AFEEEE guifg=#000000 ctermbg=159 ctermfg=16  | syn cluster cssColors add=cssColorafeeee
  hi cssColorb0c4de guibg=#B0C4DE guifg=#000000 ctermbg=152 ctermfg=16  | syn cluster cssColors add=cssColorb0c4de
  hi cssColorb0e0e6 guibg=#B0E0E6 guifg=#000000 ctermbg=152 ctermfg=16  | syn cluster cssColors add=cssColorb0e0e6
  hi cssColorb22222 guibg=#B22222 guifg=#FFFFFF ctermbg=124 ctermfg=231 | syn cluster cssColors add=cssColorb22222
  hi cssColorb8860b guibg=#B8860B guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColorb8860b
  hi cssColorba55d3 guibg=#BA55D3 guifg=#000000 ctermbg=5   ctermfg=16  | syn cluster cssColors add=cssColorba55d3
  hi cssColorbc8f8f guibg=#BC8F8F guifg=#000000 ctermbg=138 ctermfg=16  | syn cluster cssColors add=cssColorbc8f8f
  hi cssColorbdb76b guibg=#BDB76B guifg=#000000 ctermbg=247 ctermfg=16  | syn cluster cssColors add=cssColorbdb76b
  hi cssColorc0c0c0 guibg=#C0C0C0 guifg=#000000 ctermbg=250 ctermfg=16  | syn cluster cssColors add=cssColorc0c0c0
  hi cssColorc71585 guibg=#C71585 guifg=#FFFFFF ctermbg=5   ctermfg=231 | syn cluster cssColors add=cssColorc71585
  hi cssColorcd5c5c guibg=#CD5C5C guifg=#000000 ctermbg=167 ctermfg=16  | syn cluster cssColors add=cssColorcd5c5c
  hi cssColorcd853f guibg=#CD853F guifg=#000000 ctermbg=173 ctermfg=16  | syn cluster cssColors add=cssColorcd853f
  hi cssColord2691e guibg=#D2691E guifg=#000000 ctermbg=166 ctermfg=16  | syn cluster cssColors add=cssColord2691e
  hi cssColord2b48c guibg=#D2B48C guifg=#000000 ctermbg=180 ctermfg=16  | syn cluster cssColors add=cssColord2b48c
  hi cssColord3d3d3 guibg=#D3D3D3 guifg=#000000 ctermbg=252 ctermfg=16  | syn cluster cssColors add=cssColord3d3d3
  hi cssColord87093 guibg=#D87093 guifg=#000000 ctermbg=168 ctermfg=16  | syn cluster cssColors add=cssColord87093
  hi cssColord8bfd8 guibg=#D8BFD8 guifg=#000000 ctermbg=252 ctermfg=16  | syn cluster cssColors add=cssColord8bfd8
  hi cssColorda70d6 guibg=#DA70D6 guifg=#000000 ctermbg=249 ctermfg=16  | syn cluster cssColors add=cssColorda70d6
  hi cssColordaa520 guibg=#DAA520 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColordaa520
  hi cssColordc143c guibg=#DC143C guifg=#FFFFFF ctermbg=161 ctermfg=231 | syn cluster cssColors add=cssColordc143c
  hi cssColordcdcdc guibg=#DCDCDC guifg=#000000 ctermbg=253 ctermfg=16  | syn cluster cssColors add=cssColordcdcdc
  hi cssColordda0dd guibg=#DDA0DD guifg=#000000 ctermbg=182 ctermfg=16  | syn cluster cssColors add=cssColordda0dd
  hi cssColordeb887 guibg=#DEB887 guifg=#000000 ctermbg=180 ctermfg=16  | syn cluster cssColors add=cssColordeb887
  hi cssColore0ffff guibg=#E0FFFF guifg=#000000 ctermbg=195 ctermfg=16  | syn cluster cssColors add=cssColore0ffff
  hi cssColore6e6fa guibg=#E6E6FA guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColore6e6fa
  hi cssColore9967a guibg=#E9967A guifg=#000000 ctermbg=174 ctermfg=16  | syn cluster cssColors add=cssColore9967a
  hi cssColoree82ee guibg=#EE82EE guifg=#000000 ctermbg=251 ctermfg=16  | syn cluster cssColors add=cssColoree82ee
  hi cssColoreee8aa guibg=#EEE8AA guifg=#000000 ctermbg=223 ctermfg=16  | syn cluster cssColors add=cssColoreee8aa
  hi cssColorf08080 guibg=#F08080 guifg=#000000 ctermbg=210 ctermfg=16  | syn cluster cssColors add=cssColorf08080
  hi cssColorf0e68c guibg=#F0E68C guifg=#000000 ctermbg=222 ctermfg=16  | syn cluster cssColors add=cssColorf0e68c
  hi cssColorf0f8ff guibg=#F0F8FF guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorf0f8ff
  hi cssColorf0fff0 guibg=#F0FFF0 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorf0fff0
  hi cssColorf0ffff guibg=#F0FFFF guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorf0ffff
  hi cssColorf4a460 guibg=#F4A460 guifg=#000000 ctermbg=215 ctermfg=16  | syn cluster cssColors add=cssColorf4a460
  hi cssColorf5deb3 guibg=#F5DEB3 guifg=#000000 ctermbg=223 ctermfg=16  | syn cluster cssColors add=cssColorf5deb3
  hi cssColorf5f5dc guibg=#F5F5DC guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorf5f5dc
  hi cssColorf5f5f5 guibg=#F5F5F5 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorf5f5f5
  hi cssColorf5fffa guibg=#F5FFFA guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorf5fffa
  hi cssColorf8f8ff guibg=#F8F8FF guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorf8f8ff
  hi cssColorfa8072 guibg=#FA8072 guifg=#000000 ctermbg=209 ctermfg=16  | syn cluster cssColors add=cssColorfa8072
  hi cssColorfaebd7 guibg=#FAEBD7 guifg=#000000 ctermbg=7   ctermfg=16  | syn cluster cssColors add=cssColorfaebd7
  hi cssColorfaf0e6 guibg=#FAF0E6 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfaf0e6
  hi cssColorfafad2 guibg=#FAFAD2 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfafad2
  hi cssColorfdf5e6 guibg=#FDF5E6 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfdf5e6
  hi cssColorff0000 guibg=#FF0000 guifg=#FFFFFF ctermbg=196 ctermfg=231 | syn cluster cssColors add=cssColorff0000
  hi cssColorff00ff guibg=#FF00FF guifg=#FFFFFF ctermbg=13  ctermfg=231 | syn cluster cssColors add=cssColorff00ff
  hi cssColorff1493 guibg=#FF1493 guifg=#FFFFFF ctermbg=5   ctermfg=231 | syn cluster cssColors add=cssColorff1493
  hi cssColorff4500 guibg=#FF4500 guifg=#FFFFFF ctermbg=9   ctermfg=231 | syn cluster cssColors add=cssColorff4500
  hi cssColorff6347 guibg=#FF6347 guifg=#000000 ctermbg=203 ctermfg=16  | syn cluster cssColors add=cssColorff6347
  hi cssColorff69b4 guibg=#FF69B4 guifg=#000000 ctermbg=205 ctermfg=16  | syn cluster cssColors add=cssColorff69b4
  hi cssColorff7f50 guibg=#FF7F50 guifg=#000000 ctermbg=209 ctermfg=16  | syn cluster cssColors add=cssColorff7f50
  hi cssColorff8c00 guibg=#FF8C00 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColorff8c00
  hi cssColorffa07a guibg=#FFA07A guifg=#000000 ctermbg=216 ctermfg=16  | syn cluster cssColors add=cssColorffa07a
  hi cssColorffa500 guibg=#FFA500 guifg=#000000 ctermbg=3   ctermfg=16  | syn cluster cssColors add=cssColorffa500
  hi cssColorffb6c1 guibg=#FFB6C1 guifg=#000000 ctermbg=217 ctermfg=16  | syn cluster cssColors add=cssColorffb6c1
  hi cssColorffc0cb guibg=#FFC0CB guifg=#000000 ctermbg=218 ctermfg=16  | syn cluster cssColors add=cssColorffc0cb
  hi cssColorffd700 guibg=#FFD700 guifg=#000000 ctermbg=11  ctermfg=16  | syn cluster cssColors add=cssColorffd700
  hi cssColorffdab9 guibg=#FFDAB9 guifg=#000000 ctermbg=223 ctermfg=16  | syn cluster cssColors add=cssColorffdab9
  hi cssColorffdead guibg=#FFDEAD guifg=#000000 ctermbg=223 ctermfg=16  | syn cluster cssColors add=cssColorffdead
  hi cssColorffe4b5 guibg=#FFE4B5 guifg=#000000 ctermbg=223 ctermfg=16  | syn cluster cssColors add=cssColorffe4b5
  hi cssColorffe4c4 guibg=#FFE4C4 guifg=#000000 ctermbg=224 ctermfg=16  | syn cluster cssColors add=cssColorffe4c4
  hi cssColorffe4e1 guibg=#FFE4E1 guifg=#000000 ctermbg=224 ctermfg=16  | syn cluster cssColors add=cssColorffe4e1
  hi cssColorffebcd guibg=#FFEBCD guifg=#000000 ctermbg=7   ctermfg=16  | syn cluster cssColors add=cssColorffebcd
  hi cssColorffefd5 guibg=#FFEFD5 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorffefd5
  hi cssColorfff0f5 guibg=#FFF0F5 guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorfff0f5
  hi cssColorfff5ee guibg=#FFF5EE guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfff5ee
  hi cssColorfff8dc guibg=#FFF8DC guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfff8dc
  hi cssColorfffacd guibg=#FFFACD guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorfffacd
  hi cssColorfffaf0 guibg=#FFFAF0 guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorfffaf0
  hi cssColorfffafa guibg=#FFFAFA guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorfffafa
  hi cssColorffff00 guibg=#FFFF00 guifg=#000000 ctermbg=11  ctermfg=16  | syn cluster cssColors add=cssColorffff00
  hi cssColorffffe0 guibg=#FFFFE0 guifg=#000000 ctermbg=255 ctermfg=16  | syn cluster cssColors add=cssColorffffe0
  hi cssColorfffff0 guibg=#FFFFF0 guifg=#000000 ctermbg=15  ctermfg=16  | syn cluster cssColors add=cssColorfffff0
  hi cssColorffffff guibg=#FFFFFF guifg=#000000 ctermbg=231 ctermfg=16  | syn cluster cssColors add=cssColorffffff

  "call s:VimCssInit(1)

  ":augroup css
    "au!
    autocmd CursorMovedI <buffer> silent call s:ProcessByLine('.')
    autocmd ColorScheme <buffer> silent call s:VimCssInit(1)
    autocmd BufEnter <buffer> silent call s:VimCssInit(1)
  ":augroup END

  "autocmd CursorMoved  <buffer> silent call s:ProcessByLine('.')
endif
