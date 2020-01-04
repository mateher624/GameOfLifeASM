#include <stdlib.h>
#include <iostream>

int calculate()
{
	return 5;
}

extern "C" __declspec(dllexport) void calculateTheDanceFloor(int cols, int rows, int startCol, int endCol, int * table2, int * returnArray)
{
	// set rules
	int rulesSurvive[9] = { 0 };
	rulesSurvive[2] = 1;
	rulesSurvive[3] = 1;

	int rulesBorn[9] = { 0 };
	rulesBorn[3] = 1;

	// recreate table
	int **table = (int**)malloc(cols * sizeof(int*));
	for (int i = 0; i < cols; i++)
	{
		table[i] = (int*)malloc(rows * sizeof(int));
	}
	for (int i = 0; i < cols; i++)
	{
		for (int j = 0; j < rows; j++)
		{
			table[i][j] = table2[i*cols + j];
		}
	}

	// create temporary table
	//int actualCols = endCol - startCol + 1;
	int **tmpTab = (int**)malloc(cols * sizeof(int*));
	for (int i = 0; i < cols; i++)
	{
		tmpTab[i] = (int*)malloc(rows * sizeof(int));
	}
	for (int i = 0; i < cols; i++)
	{
		for (int j = 0; j < rows; j++)
		{
			tmpTab[i][j] = 0;
		}
	}

	// calculate
	int i_orig = 0;
	for (int i = startCol; i <= endCol; i++)
	{
		for (int j = 1; j < rows - 1; j++)
		{
			int aliveCount = 0;

			// X00
			// 0 0  UPPER LEFT
			// 000
			if (table[i - 1][j - 1] == 1)
			{
				aliveCount = aliveCount + 1;
			}
			// 0X0
			// 0 0  UPPER CENTER
			// 000
			if (table[i - 1][j] == 1) aliveCount = aliveCount + 1;
			// 00X
			// 0 0  UPPER RIGHT
			// 000
			if (table[i - 1][j + 1] == 1) aliveCount = aliveCount + 1;
			// 000
			// X 0  CENTER LEFT
			// 000
			if (table[i][j - 1] == 1) aliveCount = aliveCount + 1;
			// 000
			// 0 X  CENTER RIGHT
			// 000
			if (table[i][j + 1] == 1) aliveCount = aliveCount + 1;
			// 000
			// 0 0  DOWN LEFT  
			// X00
			if (table[i + 1][j - 1] == 1) aliveCount = aliveCount + 1;
			// 000
			// 0 0  DOWN CENTER
			// 0X0
			if (table[i + 1][j] == 1) aliveCount = aliveCount + 1;
			// 000
			// 0 0  DOWN RIGHT
			// 00X
			if (table[i + 1][j + 1] == 1) aliveCount = aliveCount + 1;

			int live = 0;

			for (int a = 0; a < 9; a++)
			{
				if (rulesSurvive[a] == 1 && table[i][j] == 1 && aliveCount == a)
				{
					live = 1;
				}
				else if (rulesBorn[a] == 1 && table[i][j] != 1 && aliveCount == a)
				{
					live = 1;
				}
			}
			if (live == 1)
			{
				tmpTab[i][j] = live;
			}
		}
		//i_orig++;
	}


	/*for (int i = 0; i < actualCols; i++)
	{
		for (int j = 0; j < rows; j++)
		{
			std::cout << tmpTab[i][j] << " ";
		}
		std::cout << std::endl;
	}*/

	// return
	for (size_t i = 0; i < cols; i++)
	{
		for (size_t j = 0; j < rows; j++)
		{
			returnArray[i*cols + j] = tmpTab[i][j];
		}
	}

	// free  tables
	for (int i = 0; i < cols; i++)
	{
		free(table[i]);
	}
	free(table);

	for (int i = 0; i < cols; i++)
	{
		free(tmpTab[i]);
	}
	free(tmpTab);
}
