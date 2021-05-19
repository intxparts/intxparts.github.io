# WPF Cancel ListView SelectionChanged

*2021.05.18*

A number of WPF controls follow a pattern when an event is fired for a given control, an event argument object is passed into the event handler and has a boolean field called cancel. A prime example of this is Window Closing event.

In setting that event argument's cancel field to true, this itself will cancel any further processing of the event in the action cycle.

However, not all user control events support this kind of cancellation, so other methods of cancellation must be used. The particular one I needed to handle recently was that of SelectionChanged on a given ListView/ListBox control.

Picture a wizard (stepping the user through a given set of steps) where the list of steps is a ListView control with SingleSelection. The scenario we needed to handle is the user changed some input on data that was stored in the database and we needed to prompt the user before transitioning away from that particular step. Hence in the case where a user has edited a value and then tries to navigate to another step by clicking on the ListView item directly, we want to intercept the call and prompt the user to discard changes or not. On yes, then keep moving, on no, remain on the current step.

The most straight forward solution involved using OnMousePreviewDown event on the ListView and prompting there based off of the dirty state. While there are many other solutions for handling this, there were a number of nuances involved. For example one solution in using OnMousePreviewDown that I found, the developer tried to reinvoke the MouseDownEvent on the original source control in the case where the user clicked yes to discard changes and continue with the move. However, this does not work in more complex examples of a ListView. In the ListView we were using, the content was complex, containing text, images and other small controls in the item template. This resulted in inconsistent behavior when the user would click on a ListViewItem/Step in one location vs another. For example, if the image or text was clicked on, the refiring of the event in the yes case would not properly be processed, hence the user would never transition off of the step. But if the user clicked on them empty space of the ListViewItem everything would work as expected.

As a result the most straight forward solution was just setting the SelectedItem directly for the ListView inside of the OnMousePreviewDown event handler for the yes case.

A number of other solutions were tried as well but were suboptimal:

	- resulted in too many events firing and loading data multiple times
	- incorrect behavior observed

This included binding to the SelectedItem and trying to cancel through that means. This in general is not a good idea because the UI control's values will be set to whatever the user selected and the bound object on the backend will be out of sync. There are ways to fix this, but it leads to more problems, inefficiencies.

A demo of the solution can be observed [here](https://github.com/intxparts/MicroProblem_WPFSelectionChangedCancellation)

