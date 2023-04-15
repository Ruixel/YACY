namespace YACY.Build;

public interface ICommand
{
	void Execute();
	string GetInfo();
}