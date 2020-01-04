using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GameOfLife
{
    class ArrayProcessor
    {
        public int[] ConvertToOneDimension(int[,] table, int cols, int rows)
        {
            var oneDimensionTable = new int[cols*rows];
            for (int i = 0; i < cols; i++)
            {
                for (var j = 0; j < rows; j++)
                {
                    oneDimensionTable[cols * i + j] = table[i, j];
                }
            }
            return oneDimensionTable;
        }


        public int[,] ConvertToTwoDimensions(int[] table, int cols, int rows)
        {
            var twoDimensionTable = new int[cols, rows];
            for (int i = 0; i < cols; i++)
            {
                for (int j = 0; j < rows; j++)
                {
                    if (table[cols * i + j] != 0) table[cols * i + j] = 1;
                    twoDimensionTable[i,j] = table[cols * i + j];
                }
            }
            return twoDimensionTable;
        }
    }
}
