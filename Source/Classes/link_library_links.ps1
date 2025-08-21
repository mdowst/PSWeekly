Add-Type -AssemblyName System.Web
enum WeeklyCategory {
    Announcements = 58
    BlogsArticlesAndPosts = 12
    BooksMediaAndLearningResources = 4
    Community = 1143
    Fun = 7
    ProjectsScriptsAndModules = 9
    UpcomingEvents = 17
}

class WeeklyCategoryHelper {
    static [hashtable] $DisplayNames = @{
        [WeeklyCategory]::Announcements = "Announcements!"
        [WeeklyCategory]::BlogsArticlesAndPosts = "Blogs, Articles, and Posts"
        [WeeklyCategory]::BooksMediaAndLearningResources = "Books, Media, and Learning Resources"
        [WeeklyCategory]::Community = "Community"
        [WeeklyCategory]::Fun = "Fun"
        [WeeklyCategory]::ProjectsScriptsAndModules = "Projects, Scripts, and Modules"
        [WeeklyCategory]::UpcomingEvents = "Upcoming Events"
    }

    static [hashtable] $DisplayOrder = @{
        [WeeklyCategory]::Announcements = 0
        [WeeklyCategory]::BlogsArticlesAndPosts = 1
        [WeeklyCategory]::BooksMediaAndLearningResources = 2
        [WeeklyCategory]::Community = 3
        [WeeklyCategory]::Fun = 4
        [WeeklyCategory]::ProjectsScriptsAndModules = 5
        [WeeklyCategory]::UpcomingEvents = 6
    }
    
    static [string] GetDisplayName([WeeklyCategory]$category) {
        return [WeeklyCategoryHelper]::DisplayNames[$category]
    }

    static [int] GetDisplayOrder([WeeklyCategory]$category) {
        return [WeeklyCategoryHelper]::DisplayOrder[$category]
    }
}

class link_library_links {
    [String]$Title
    [String]$Link
    [DateTime]$Date
    [String]$Author
    [String]$Description
    [WeeklyCategory]$WeeklyCategory
    [Object[]]$Category
    [Object[]]$Tags
    
    # Property to get the display name of the WeeklyCategory
    [string] GetWeeklyCategoryDisplayName() {
        return [WeeklyCategoryHelper]::GetDisplayName($this.WeeklyCategory)
    }

    link_library_links([object]$InputObject) {
        $this.Title = [System.Web.HttpUtility]::HtmlDecode($InputObject.title.rendered)
        $this.Link = $InputObject.link
        $this.Date = $InputObject.date
        $this.Author = $InputObject.meta.link_submitter_name
        
        $this.Category = $InputObject.link_library_category
        $this.Tags = $InputObject.link_library_tags

        if(-not [string]::IsNullOrEmpty($InputObject.meta.link_description)) {
            $DescriptionStr = $InputObject.meta.link_description.Replace('[expand title=(+) trigclass=my_button trigpos=below swaptitle=(-) targpos=inline] ','').Replace(' [/expand]','')
            $this.Description = [System.Web.HttpUtility]::HtmlDecode($DescriptionStr)
        }
        
        # Find the category ID that matches a WeeklyCategory enum value
        $enumValues = [WeeklyCategory].GetEnumValues()
        $matchingCategoryId = $InputObject.link_library_category | Where-Object { $_ -in $enumValues }
        
        if ($matchingCategoryId) {
            $this.WeeklyCategory = [WeeklyCategory]$matchingCategoryId
        } else {
            $this.WeeklyCategory = [WeeklyCategory]::BlogsArticlesAndPosts # Default fallback
        }
    }
    
}