# ListViewItem not stretching to width of container

*2021.01.16*

Solution:

```
<ListView.ItemContainerStyle>
    <Style TargetType="ListViewItem">
        <Setter Property="HorizontalContentAlignment" Value="Stretch" />
    </Style>
</ListView.ItemContainerStyle>
```

