$posts = Get-ChildItem .\blog\content\post\2022

Describe "Test Frontmatter" {
    It "Returns <expected> (<name>)" -ForEach $posts {
        Get-Content $name | ogv
        $Name | should -BeNullOrEmpty
    }
}
