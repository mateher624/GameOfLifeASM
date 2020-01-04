using System;
using System.Diagnostics;
using System.Threading;

namespace GameOfLife
{
    class Program
    {
        private const int tableCols = 42;
        private const int tableRows = 42;
        private static bool spectatorMode = true;
        private static int parts = 4;
        private static string patternName = "random";
        private static int generations = 10000;
        private static bool asmMode = true;

        private static void Main(string[] args)
        {
            ParseArgs(args);

            int rectThreadsCount, directThreadsCount;
            var table = new int[tableCols, tableRows]; // 40 + offset
            ThreadPool.GetAvailableThreads(out directThreadsCount, out rectThreadsCount);

            Console.WriteLine("Please press any key to start.");
            Console.ReadLine();
            
            var patternReader = new FileReader();
            patternReader.ReadPattern(@"patterns\"+patternName, ref table, tableCols, tableRows);

            PrintPattern(table);
            Thread.Sleep(100);

            var timeDiff = 0;
            var threader = new Threader(tableCols, tableRows, parts, asmMode);

            if (spectatorMode)
            {
                for (var k = 0; k < generations; k++)
                {
                    threader.Run(ref table);
                    PrintPattern(table);
                    Thread.Sleep(100);
                }
            }
            else
            {
                
                var start = Environment.TickCount & int.MaxValue;
                for (int k = 0; k < generations; k++)
                {
                    threader.Run(ref table);
                }
                var stop = Environment.TickCount & int.MaxValue;
                timeDiff = stop - start;
            }

            PrintPattern(table);
            Console.WriteLine("Czas pracy: " + timeDiff);
            Console.ReadKey();
        }

        private static void PrintPattern(int[,] table)
        {
            Console.Clear();
            for (var i = 0; i < tableCols; i++)
            {
                Console.WriteLine();
                for (var j = 0; j < tableRows; j++)
                {
                    Console.Write((table[i, j] == 1) ? "☻" : " ");
                }
            }
            Console.WriteLine();
        }

        private static void ParseArgs(string[] args)
        {
            try
            {
                for (var i = 0; i < args.Length; i++)
                {
                    switch (args[i])
                    {
                        case "/threads":
                            parts = int.Parse(args[i + 1]);
                            break;
                        case "/spectator":
                            spectatorMode = string.Equals(args[i + 1].ToUpperInvariant(), "TRUE");
                            break;
                        case "/pattern":
                            patternName = args[i + 1];
                            break;
                        case "/generations":
                            generations = int.Parse(args[i + 1]);
                            break;
                        case "/mode":
                            asmMode = string.Equals(args[i + 1].ToUpperInvariant(), "ASM");
                            break;
                    }
                }
            }
            catch (Exception)
            {
                Console.WriteLine("Error parsing arguments. Setting default arguments.");
                parts = 4;
            }
            
        }
    }
}
