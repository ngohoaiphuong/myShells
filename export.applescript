on run argv
   tell application "/Users/ngohoaiphuong/sources/tools/CoverStory.app"
       quit
       activate
       set x to open (item 1 of argv)
       tell x to export to HTML in (item 2 of argv)
       quit
   end tell   
end run