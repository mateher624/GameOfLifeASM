using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace GameOfLife
{
    internal class Threader
    {
        //private List<Thread> threads;
        private readonly List<ManualResetEvent> events;

        private readonly int tableCols;
        private readonly int tableRows;
        private readonly int parts;
        private readonly bool asmMode;

        public Threader(int tableCols, int tableRows, int parts, bool asmMode)
        { 
            //threads = new List<Thread>();
            events = new List<ManualResetEvent>();
            this.parts = parts;
            this.tableCols = tableCols;
            this.tableRows = tableRows;
            this.asmMode = asmMode;
        }

        internal void Run(ref int[,] table)
        {
            events.Clear();
            var workers = new List<Worker>();

            for (int i = 0; i < parts; i++)
            {
                var resetEvent = new ManualResetEvent(false);
                var tableShard = new TableShard(tableCols, tableRows, parts, i);
                var worker = new Worker(i, tableShard, ref table, tableCols, tableRows, asmMode);
                workers.Add(worker);
                ThreadPool.QueueUserWorkItem(
                    arg =>
                    {
                        worker.ExecuteOrder66();
                        resetEvent.Set();
                    });
                events.Add(resetEvent);
            }
            WaitHandle.WaitAll(events.ToArray());
            foreach (var worker in workers) worker.Reassemble();
        }
    }
}
