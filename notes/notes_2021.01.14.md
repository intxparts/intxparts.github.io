# ListView Quirks

*2021.01.14*

### Changing ListView SelectionMode at runtime 

[SelectionMode](https://docs.microsoft.com/en-us/dotnet/api/system.windows.controls.selectionmode?view=net-5.0) cannot be changed dynamically once the control has been rendered, at least not without rebinding. However, calling a function to initialize the Window/UserControl before being loaded can allow you to properly set the SelectionMode based on given input.

Perhaps it might be better to consider creating two separate controls instead of attempting to manage two potential different UI workflows in a single control. It depends on the situation.


```csharp
public class MyViewModel : IViewModel<InputModel, OutputModel>
{
    public MyViewModel()
    {
        _selectionMode = SelectionMode.Single;
    }

    private SelectionMode _selectionMode;
    public SelectionMode => _selectionMode;

    public InputModel Input { get; set; }
    public OutputModel Output { get; private set; }

    public void Initialize(IAppContainer container)
    {
        if (Input.UseMultiSelect)
            _selectionMode = SelectionMode.Multiple;
    }
}

public class ViewService : IViewService
{
    public TView CreateView<TView, TViewModel, TInputModel, TOutputModel>(TInputModel input)
    {
        var view = new TView();
        var viewModel = new TViewModel();
        
        view.Input = input;
        view.Initialize(_container);
        view.DataContext = viewModel;
        return view;
    }
}
```

### Hiding ListView Header
By default ListView has a header. It can easily be hidden using the following style.

```xaml
<ListView>
    <ListView.Resources>
        <Style x:Key="HideHeaderStyle" TargetType="{x:Type GridViewColumnHeader}">
            <Setter Property="Visibility" Value="Collapsed" />
        </Style>
    </ListView.Resources>
</ListView>
```

### Scrolling ListView with mouse wheel

Suppose you have a set of controls including a list view that need to be wrapped in a ScrollViewer so that users can appropriately scroll/navigate to all controls. ListView already has a built-in ScrollViewer. One way to get a decent user experience is to hide the scroll bars for the ListView and then tie in the mouse wheel movement to the wrapper ScrollViewer so that all the content can be reached.

```xaml

<ScrollViewer Name="sviewer"
    VerticalScrollBarVisibility="Auto"
    HorizontalScrollBarVisibility="Disabled"
    PanningMode="VerticalOnly"
    CanContentScroll="False">
    <!-- More controls here

    --> 
    <ListView 
        PreviewMouseWheel="ListView_PreviewMouseWheel">
    </ListView> 
</ScrollViewer>
```

```csharp
// code behind

private void ListView_PreviewMouseWheel(object sender, MouseWheelEventArgs e)
{
    if (e.Delta < 0)
    {
        sviewer.LineDown();
    }
    else
    {
        sviewer.LineUp();
    }
}
```

