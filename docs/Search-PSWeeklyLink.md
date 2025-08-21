---
external help file: PSWeekly-help.xml
Module Name: PSWeekly
online version: 
schema: 2.0.0
---

# Search-PSWeeklyLink

## SYNOPSIS

Searches for PSWeekly links based on specified criteria.

## SYNTAX

### Search (Default)

```
Search-PSWeeklyLink [-MaxResults <Int32>] [-ProgressAction <ActionPreference>] [-Search <String>] [<CommonParameters>]
```

## DESCRIPTION

This function allows users to search for PSWeekly links using various parameters.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Search-PSWeeklyLink -Search "VSCode" -MaxResults 5
```








## PARAMETERS

### -MaxResults

The maximum number of results to return.
Results are returned in descending order by date.
If set to 0, it returns all results.

```yaml
Type: Int32
Parameter Sets: Search
Aliases: 
Accepted values: 

Required: True (None) False (Search)
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Search

The search term to filter PSWeekly links.

```yaml
Type: String
Parameter Sets: Search
Aliases: 
Accepted values: 

Required: True (None) False (Search)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

General notes


## RELATED LINKS

Fill Related Links Here

