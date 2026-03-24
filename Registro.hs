import System.IO
import Text.Read (readMaybe)

type Estudiante = (String, Int)
type Universidad = [Estudiante]

archivo :: String
archivo = "University.txt"

main :: IO ()
main = do
    contenido <- readFile archivo
    let estudiantes = length contenido `seq` read contenido :: Universidad
    menu estudiantes

menu :: Universidad -> IO ()
menu ests = do
    putStrLn "\n--- SISTEMA DE REGISTRO UNIVERSIDAD ---"
    putStrLn "1) Check In"
    putStrLn "2) Buscar por ID"
    putStrLn "3) Calculo de Tiempo"
    putStrLn "4) Listar Estudiantes"
    putStrLn "5) Check Out"
    putStrLn "0) Salir"
    putStr "Elige una opcion: "
    opcion <- getLine
    
    case opcion of
        "1" -> checkIn ests
        "2" -> buscar ests
        "3" -> calcularTiempo ests
        "4" -> listar ests
        "5" -> checkOut ests
        "0" -> putStrLn "\nSaliendo del sistema..."
        _   -> putStrLn "\nOpcion invalida." >> menu ests

checkIn :: Universidad -> IO ()
checkIn ests = do
    putStr "Ingrese ID del estudiante: "
    idEst <- getLine
    
    case buscarEstudiante idEst ests of
        Just _  -> do
            putStrLn "-> Error: El estudiante ya se encuentra registrado en el sistema."
            menu ests
        Nothing -> do
            putStr "Ingrese hora de entrada (minutos desde 00:00, ej. 480): "
            horaStr <- getLine
            
            case readMaybe horaStr :: Maybe Int of
                Just hora -> do
                    let nuevosEsts = (idEst, hora) : ests
                    guardar nuevosEsts
                    putStrLn "-> Estudiante registrado exitosamente."
                    menu nuevosEsts
                Nothing -> do
                    putStrLn "-> Error: Formato de hora invalido. Por favor, ingresa un numero entero."
                    menu ests

buscar :: Universidad -> IO ()
buscar ests = do
    putStr "Ingrese ID a buscar: "
    idEst <- getLine
    case buscarEstudiante idEst ests of
        Just (i, h) -> putStrLn $ "-> Estudiante " ++ i ++ " esta en la universidad. Entro a los " ++ show h ++ " minutos."
        Nothing     -> putStrLn "-> Estudiante no encontrado o ya salio."
    menu ests

calcularTiempo :: Universidad -> IO ()
calcularTiempo ests = do
    putStr "Ingrese ID del estudiante: "
    idEst <- getLine
    case buscarEstudiante idEst ests of
        Just (_, hEntrada) -> do
            putStr "Ingrese hora actual (minutos desde 00:00): "
            hSalidaStr <- getLine
            
            case readMaybe hSalidaStr :: Maybe Int of
                Just hSalida -> 
                    if hSalida >= hEntrada 
                        then do
                            let duracion = hSalida - hEntrada
                                horas = duracion `div` 60
                                minutos = duracion `mod` 60
                            putStrLn $ "-> Tiempo de permanencia: " ++ show horas ++ " horas y " ++ show minutos ++ " minutos."
                        else putStrLn "-> Error: La hora actual no puede ser anterior a la hora de entrada."
                Nothing -> putStrLn "-> Error: Formato invalido. Ingresa un numero entero."
        Nothing -> putStrLn "-> Estudiante no encontrado."
    menu ests

listar :: Universidad -> IO ()
listar ests = do
    putStrLn "\n--- Estudiantes Registrados ---"
    if null ests
        then putStrLn "-> No hay ningun estudiante registrado en este momento."
        else print ests
    menu ests

checkOut :: Universidad -> IO ()
checkOut ests = do
    putStr "Ingrese ID del estudiante a dar salida: "
    idEst <- getLine
    case buscarEstudiante idEst ests of
        Just (_, hEntrada) -> do
            putStr "Ingrese hora de salida (minutos desde 00:00): "
            hSalidaStr <- getLine
            
            case readMaybe hSalidaStr :: Maybe Int of
                Just hSalida -> 
                    if hSalida >= hEntrada
                        then do
                            let duracion = hSalida - hEntrada
                                nuevosEsts = eliminarEstudiante idEst ests
                            guardar nuevosEsts
                            putStrLn $ "-> Check Out exitoso. Tiempo total: " ++ show duracion ++ " minutos."
                            menu nuevosEsts
                        else do
                            putStrLn "-> Error: La hora de salida no puede ser anterior a la hora de entrada."
                            menu ests
                Nothing -> do
                    putStrLn "-> Error: Formato invalido. Ingresa un numero entero."
                    menu ests
        Nothing -> do
            putStrLn "-> Estudiante no encontrado."
            menu ests

guardar :: Universidad -> IO ()
guardar ests = writeFile archivo (show ests)

buscarEstudiante :: String -> Universidad -> Maybe Estudiante
buscarEstudiante _ [] = Nothing
buscarEstudiante idBuscado ((i, h):resto)
    | idBuscado == i = Just (i, h)
    | otherwise      = buscarEstudiante idBuscado resto

eliminarEstudiante :: String -> Universidad -> Universidad
eliminarEstudiante _ [] = []
eliminarEstudiante idBuscado ((i, h):resto)
    | idBuscado == i = resto
    | otherwise      = (i, h) : eliminarEstudiante idBuscado resto