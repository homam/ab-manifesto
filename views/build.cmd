ls "*.ls" -r | %{lsc -c $_.FullName}
ls "*.styl" -r | %{stylus $_.FullName}