# WPF Style.Triggers

*2021.04.13*

Needed to have a textblock's foreground change depending on whether the mouse was over it or if the item itself was selected in a ListView.

```xaml
<Style x:Key="TextBlockStyle" TargetType="{x:Type TextBlock}">
	<Setter Property="Foreground"
			Value="{StaticResource DefaultTextForeground}" />
	<Style.Triggers>
		<MultiDataTrigger>
			<MultiDataTrigger.Conditions>
				<Condition Binding="{Binding RelativeSource={RelativeSource Mode=FindAncestor, AncestorType={x:Type ListViewItem}}, Path=IsMouseOver}" Value="True" />
				<Condition Binding="{Binding RelativeSource={RelativeSource Mode=FindAncestor, AncestorType={x:Type ListViewItem}}, Path=IsSelected}" Value="False" />
			</MultiDataTrigger.Conditions>
			<Setter Property="Foreground" Value="{StaticResource DesiredForeground}" />
		</MultiDataTrigger>
		<DataTrigger Binding="{Binding RelativeSource={RelativeSource Mode=FindAncestor, AncestorType={x:Type ListViewItem}}, Path=IsSelected}" Value="True">
			<Setter Property="Foreground" Value="{StaticResource SelectedForeground}" />
		</DataTrigger>
	</Style.Triggers>
</Style>



```

Usage:

```xaml
<TextBlock Text="Information" Style="{StaticResource TextBlockStyle}" />
```

