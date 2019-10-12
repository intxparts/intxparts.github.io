pandoc -f gfm -t html -s -o index.html index.md --metadata pagetitle="Old Jim's General Dev Store"
pandoc -f gfm -t html -s -o notes.html notes.md --metadata pagetitle="Old Jim's Notes"
pandoc -f gfm -t html -s -o tools.html tools.md --metadata pagetitle="Old Jim's Toolbox"
pandoc -f gfm -t html -s -o games.html games.md --metadata pagetitle="Old Jim's Game Shelf"
