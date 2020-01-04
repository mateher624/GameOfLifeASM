using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace GameOfLife
{
    internal class Worker
    {
        [DllImport(@"C:\Users\Mateusz\Source\Repos\Asembler\JA_M.Herjan_GameOfLife\Zrodla\x64\Debug\DLL_C.dll", EntryPoint = "calculateTheDanceFloor", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void calculateTheDanceFloorC(int rows, int cols, int startCol, int startRow, int[] table, int[] returnArray);
        [DllImport(@"C:\Users\Mateusz\Source\Repos\Asembler\JA_M.Herjan_GameOfLife\Zrodla\x64\Debug\DLL_ASM.dll", EntryPoint = "calculateTheDanceFloor")]
        public static extern int calculateTheDanceFloorASM(int rows, int cols, int startCol, int startRow, int[] table, int[] returnArray);

        public int Number;
        public TableShard TableShard { get; set; }
        private readonly int[,] table;
        private readonly int cols;
        private readonly int rows;
        private readonly bool asmMode;

        public Worker(int number, TableShard tableShard, ref int[,] table, int cols, int rows, bool asmMode)
        {
            Number = number;
            this.TableShard = tableShard;
            this.table = table;
            this.cols = cols;
            this.rows = rows;
            this.asmMode = asmMode;
        }

        public void Execute()
        {
            bool end = false;
            int counter = 0;
            while (!end)
            {
                
                counter++;
                if (counter == 100) end = true;
            }
        }

        public void ExecuteOrder66()
        {
            var arrayProcessor = new ArrayProcessor();
            var returnArray = new int[cols * rows];
            var oneDimensionArray = arrayProcessor.ConvertToOneDimension(table, cols, rows);
            try
            {
                if (asmMode) calculateTheDanceFloorASM(cols, rows, TableShard.StartColumn, TableShard.EndColumn, oneDimensionArray, returnArray);
                else calculateTheDanceFloorC(cols, rows, TableShard.StartColumn, TableShard.EndColumn, oneDimensionArray, returnArray);
            }
            catch (Exception)
            {
                throw new Exception("Error during calculations please contact developer.");
            }
            finally
            {
                TableShard.Contents = arrayProcessor.ConvertToTwoDimensions(returnArray, cols, rows);
            } 
        }

        public void Reassemble()
        {
            //var iOrig = 0;
            for (int i = TableShard.StartColumn; i <= TableShard.EndColumn; i++)
            {
                for (int j = 0; j < rows; j++)
                {
                    this.table[i, j] = TableShard.Contents[i, j];
                }
                //iOrig++;
            }
        }
    }
}


