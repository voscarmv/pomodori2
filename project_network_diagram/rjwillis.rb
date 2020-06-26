# Algorithm from https://doi.org/10.1016/0305-0548(85)90041-3
# An algorithm for constructing project network diagrams on an ordinary line printer
# R.J.Willis†
nodes = [1, 2, 3, 4, 5]
startnode = 1
endnode = 5
edges = [
  [1, 2],
  [1, 3],
  [1, 4],
  [2, 3],
  [2, 5],
  [4, 5],
  [3, 5]  
]

edges.shuffle!

# Khan's algorithm for topo-sort

pnd = []
nextnodes = [startnode]

until nextnodes.empty?
  v = nextnodes[0]
  nextnodes.delete(v)

  neighboredges = edges.select{|e| e[0] == v }
  neighboredges.sort_by!{|x, y| y}
  pnd += neighboredges

  neighboredges.each{ |e|
    edges.delete(e)
    neighbor = e[1]
    incoming = edges.select{|e| e[1] == neighbor}
    p incoming
    if incoming.empty?
      nextnodes.push(neighbor)
    end
  }
end

prev = pnd[0][0]
nest1 = 1
pnd.map! { |e|
  if e[0] != prev
    nest1 += 1
    prev = e[0]
  end
  e = [e, nest1]
}

p pnd

# pnd = [
#   [[1, 2], 1],
#   [[1, 3], 1],
#   [[1, 4], 1],
#   [[2, 3], 2],
#   [[2, 5], 2],
#   [[4, 5], 3],
#   [[3, 5], 4]  
# ]

# nodes = [1, 2, 3, 4, 5, 6, 7, 8, 9]
# pnd = [
#   [[1, 2], 1],
#   [[1, 3], 1],
#   [[1, 4], 1],
#   [[2, 5], 2],
#   [[3, 5], 3],
#   [[4, 5], 4],
#   [[5, 6], 5],
#   [[5, 7], 5],
#   [[5, 8], 5],
#   [[6, 9], 6],
#   [[7, 9], 7],
#   [[8, 9], 8],
# ]

table = Array.new(nodes.length){Array.new(1,0)}

pnd.each{ |activity|

  puts "TABLE START"
  table.each{ |r|
    p r
  }

  startnode = activity[0][0]
  nest1s = activity[1]

  endnode = activity[0][1]
  ix = pnd.index { |a| a[0][0] == endnode }

  if ix
    nest1e = pnd[ix][1]
  else
    nest1e = nodes.length
  end

  puts "#{startnode},#{endnode}"
  x = table[nest1s - 1].index {|c| c != 0}
  unless x
    x = 0
  end
  cols = table.transpose

  found = false
  while x < cols.length do
    puts "colx"
    p cols[x]
    cols[x].delete_at(nest1e-1)
    cols[x].shift(nest1s)
    if cols[x].all?(0)
      table[nest1s-1][x] = startnode
      table[nest1e-1][x] = endnode
      found = true
      puts "found1"
      break
    end
    x += 1
  end
  until found do
    table.each{ |row|
      row.push(0)
    }
    cols = table.transpose
    cols[x].delete_at(nest1e-1)
    cols[x].shift(nest1s)
    if cols[x].all?(0)
      table[nest1s-1][x] = startnode
      table[nest1e-1][x] = endnode
      found = true
      puts "found2"
    end
    x += 1    
  end

  puts "TABLE END"
  table.each{ |r|
    p r
  }

}

puts "FINAL TABLE"
table.each{ |r|
  p r
}

plot = Array.new()

plot.push(Array.new(table[0].length,"   "))
i = 1
cols = table.transpose
table.each_with_index{ |r, k|
  5.times{
    plot.push(Array.new(r.length,"   "))
  }
  e = r.index { |c| c != 0 }
  plot[i][e] = "---"
  plot[i+1][e] = " #{r[e]} "
  plot[i+2][e] = "---"
  lf = false
  rf = false
  l1 = true
  r1 = true
  r.reverse.each_with_index{ |v, j|
    ix = r.length - 1 - j
    if v != 0
      colcpy = cols[ix].dup
      colcpy.shift(k+1)
      puts "val #{v}"
      puts "col #{colcpy}"
      puts "col shift #{colcpy}"
      puts "col shift index #{colcpy.index {|c| c != 0}}"
      below = colcpy.index {|c| c != 0}
      if below
        plot[i+3][ix] = " v "
        plot[i+4][ix] = " v "
      end
      if ix != e
        # puts "plot[i-1][ix] #{plot[i-1][ix]}"
        if plot[i-1][ix] == " v "
          lf = true
        end
        if below
          rf = true
          plot[i+3][ix] = " v "
          plot[i+4][ix] = " v "
        end  
      end
    end
    if ix != e
      if plot[i-1][ix] == " v "
        if !lf && !rf
          plot[i][ix] = " v "
          plot[i+1][ix] = " v "
          plot[i+2][ix] = " v "
          plot[i+3][ix] = " v "
          plot[i+4][ix] = " v "
        end
        if !lf && rf
          plot[i][ix] = " v "
          plot[i+1][ix] = " v "
          plot[i+2][ix] = ">v>"
          plot[i+3][ix] = " v "
          plot[i+4][ix] = " v "
        end
        if lf && !rf
          if l1
            plot[i][ix] = "<< "
            l1 = false
          else
            plot[i][ix] = "<<<"
          end
        end
        if lf && rf
          if l1
            plot[i][ix] = "<< "
            l1 = false
          else
            plot[i][ix] = "<<<"
          end
          if r1
            plot[i+2][ix] = ">> "
            r1 = false
          else
            plot[i+2][ix] = ">>>"
          end
        end
      else
        if !lf && rf
          if r1
            plot[i+2][ix] = ">> "
            r1 = false
          else
            plot[i+2][ix] = ">>>"
          end
        end
        if lf && !rf
          if l1
            plot[i][ix] = "<< "
            l1 = false
          else
            plot[i][ix] = "<<<"
          end
        end
        if lf && rf
          if l1
            plot[i][ix] = "<< "
            l1 = false
          else
            plot[i][ix] = "<<<"
          end
          if r1
            plot[i+2][ix] = ">> "
            r1 = false
          else
            plot[i+2][ix] = ">>>"
          end
        end
      end
    end
  }
  puts "this"
  p plot[i-1]
  i+=5
}

puts "PLOT"
plot.each{ |r|
  puts r.join
}