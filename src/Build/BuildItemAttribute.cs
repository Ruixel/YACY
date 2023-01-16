using YACY.Util;

namespace YACY.Build;

[System.AttributeUsage(System.AttributeTargets.Class)]
public class BuildItemAttribute : System.Attribute
{
	public string ItemPanelPreview;
	public string SelectionPreview;

	public string Name;
	public ToolType Tool;
}