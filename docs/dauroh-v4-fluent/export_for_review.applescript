on run argv
    set pptPath to item 1 of argv
    set pdfPath to item 2 of argv
    with timeout of 1800 seconds
        tell application "Microsoft PowerPoint"
            open (POSIX file pptPath)
            set theDeck to active presentation
            save theDeck in (POSIX file pdfPath) as save as PDF
            close theDeck saving no
        end tell
    end timeout
end run
