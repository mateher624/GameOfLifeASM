using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GameOfLife
{
    class TableShard
    {
        public int StartColumn { get; set; }
        public int EndColumn { get; set; }
        public int[,] Contents { get; set; }

        public int Cols { get; set; }
        public int Rows { get; set; }

        public TableShard(int cols, int rows, int parts, int currentPart)
        {
            cols = cols - 2; // borderless
            int elementsPerWorker = cols / parts;
            StartColumn = currentPart * elementsPerWorker + 1;              //   \
            if (parts - 1 == currentPart) EndColumn = cols - 1 + 1;         //    >   starts with 1 ends with max - 1;
            else EndColumn = (currentPart + 1) * elementsPerWorker - 1 + 1; //   /
            Cols = EndColumn - StartColumn + 1;
            Rows = rows;
            Contents = new int[Cols, Rows];
        }
    }
}
