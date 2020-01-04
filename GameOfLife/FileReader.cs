using System;
using System.IO;
using System.Text.RegularExpressions;

namespace GameOfLife
{
    internal class FileReader
    {
        public void ReadPattern(string name, ref int[,] table, int tableX, int tableY)
        {
            try
            {
                if (string.Equals(name, @"patterns\random"))
                {
                    var random = new Random();
                    for (int i = 0; i < tableX*tableY/2; i++)
                    {
                        var x = random.Next(tableX - 2);
                        var y = random.Next(tableY - 2);
                        table[x + 1, y + 1] = 1;
                    }
                }
                else
                {
                    var lines = File.ReadAllText(name);
                    var matchCollection = Regex.Matches(lines, @"x[ ]*([0-9]+)y[ ]*([0-9]+)");

                    foreach (Match match in matchCollection)
                    {
                        int x;
                        int y;
                        int.TryParse(match.Groups[1].Value, out x);
                        int.TryParse(match.Groups[2].Value, out y);
                        table[x + 1, y + 1] = 1;
                    }
                }
                
            }
            catch (Exception)
            {
                Console.WriteLine("Error reading file.");
                throw;
            }  
        }
    }
}
