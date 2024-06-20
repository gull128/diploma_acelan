// See https://aka.ms/new-console-template for more information
using System;
using System.Collections.Generic;
using System.Net;
using System.Linq;
using System.Diagnostics;
using System.Net.Http;
using System.Net.Sockets;
using System.Text;
using Acelan.Fem;
using Acelan.Fem.DataSources;
using Acelan.Fem.Elements;
using Acelan.Fem.Materials;
using Acelan.Triangulation;
using Acelan.Triangulation.MaterialConverters;
using Acelan.Triangulation.XmlFormat;
using Acelan.Bee;
using Body = Acelan.Fem.Body;
using Task = System.Threading.Tasks.Task;
using Acelan.Fdm;
using static alglib;
using Acelan.SpaceMatrix;
using Newtonsoft.Json;
using log4net;
using Newtonsoft.Json.Linq;

namespace Acelan.Bee
{
    class Program
    {
        public class Config
        {
            public string secret { get; set; }
            public string octave_path { get; set; }
        }

        private static double _delta = 0.01;
        private static readonly MaterialLibrary _library;
        private static Config _config;

        static async Task Main(string[] args)
        {
            Console.WriteLine(Environment.CurrentDirectory);
            
            // Create a TcpListener on any IP at port 13000
            TcpListener server = new TcpListener(IPAddress.Any, 13000);

            // Start listening for client requests
            server.Start();

            // Buffer for reading data
            Byte[] bytes = new Byte[256];
            String data = null;
            String itog = null;

            // Enter the listening loop
            while (true)
            {
                Console.Write("Waiting for a connection... ");

                // Perform a blocking call to accept requests
                TcpClient client = server.AcceptTcpClient();
                Console.WriteLine("Connected!");

                data = null;
                itog = null;
                NetworkStream stream = client.GetStream();

                int i; 
                //stream.Write(Encoding.ASCII.GetBytes("OK"));
                while ((i = stream.Read(bytes, 0, bytes.Length)) != 0)
                {
                    data = Encoding.ASCII.GetString(bytes, 0, i);
                    if (data == null)
                    {
                        break;
                    }
                    Console.WriteLine("Received: {0}", data);
                    Console.WriteLine(data.Contains("str"));
                    if (data.Contains("str"))
                    {
                        Console.WriteLine(Environment.CurrentDirectory+"\n");
                        stream.Write(Encoding.ASCII.GetBytes(Environment.CurrentDirectory+"\n"));
                        break;
                    }
                    // Perform task
                    dynamic argdFromData = JsonConvert.DeserializeObject(data);
                    int num1 = argdFromData.num1; // Первое число = 144
                    int num2 = argdFromData.num2; // Второе число = 98
                    int num1xnum2 = argdFromData.num1xnum2; // Второе число = 98
                    string fileName1 = argdFromData.fileName1; // ParamCalc
                    string fileName2 = argdFromData.fileName2; //ParamSid2024
                    string timestamp = argdFromData.time;
                    Console.WriteLine(timestamp);
                    
                    try
                    {
                        SolverFinDiff sfd = new SolverFinDiff(num1, num2, num1xnum2, fileName1, fileName2, timestamp);
                        sfd.ProgramAlglib();
                        stream.Write(Encoding.ASCII.GetBytes("OK\n"));
                    }
                    catch (Exception ex)
                    {
                        itog =$"ERROR ProgramAlglib(): {ex.Message}\n";
                        Console.WriteLine(itog);
                        stream.Write(Encoding.ASCII.GetBytes(itog));
                    }
                    
                }
                byte[] msg1 = Encoding.ASCII.GetBytes("OK");
                client.GetStream().Write(msg1);
                client.Close();
            }
        }


        private static void SendResults(string result, string url)
        {

            //send result as body at callback_url
            HttpClient client = new HttpClient();
            var data = new StringContent(result, Encoding.UTF8, "application/json");
            var res = client.PostAsync(url, data).Result;

        }
        // TODO
        /*  1. распарсить строку с задачей, убедиться, что мы понимаем такую команду
                формат command_name(param1, param2, [param3])
            2. Вызвать нужную функцию из библиотеки
            Пример того, как сделать mix, лежит в файле
            acelan\Acelan.Tests\FemTests\ModelsTest.cs, метод TestElectric8
            3. Сделать JSON

        Смотрите, у вас сейчас команда такая:
        command_name(param1, param2, [param3]) - это общий шаблон для любой команды.

        Вам надо сделать вот эту:

        mix(0.5, "3-3") - первый параметр - число, второй - строка.
        */

        private static IMaterialConverter ChoosingMoethods(string method)
        {
            switch (method)
            {
                case "3-3":
                    return new CoherentConverter(1, 2);
                case "2-2":
                    return new CustomConverter(2, 2, "");
                default:
                    throw new ArgumentException("Invalid method"); // Вернуть исключение, если метод неизвестен
            }

            ;
        }
        
        public static Model SetupModel(List<Variable> variables, int depth, string boundaryConditions = null)
        {
            var converter = new ThreeOneConverter(0, 1);
            var mesh = new OctreeTriangulator(Triangulation.Body.Default(), converter, 0, 0)
                .Triangulate(depth);
            var unit = new XmlFormat(Triangulation.Body.Default(), mesh);
            var dataSource = new OctreeDataSource();
            dataSource.Init(unit);
            var model = new Model(dataSource);
            model.SetBodies(new[]
            {
                new Body(_library.GetMaterial("PZT-4C"),
                    variables,
                    ElementFactory.BuildElement(ElementType.Hex8, variables), null, 0)
            });
            model.GetMesh().ReenumByPosition();

            if (boundaryConditions != null)
            {
                new ScriptParser().ParseBoundaryConditions(boundaryConditions, ref model);
            }

            return model;
        }
    }
}








