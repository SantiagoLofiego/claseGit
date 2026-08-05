# Clase 01 - Cheatsheet

---

## Estructura del proyecto por capas

```
src/main/java/com/capacitacion/ecommerce/
├── controller/       <- Recibe los requests HTTP y devuelve responses
│   └── ProductController.java
├── service/          <- Contiene la logica de negocio
│   └── ProductService.java
├── dto/              <- Objetos de transferencia de datos (entrada y salida de la API)
│   ├── ProductRequestDto.java
│   ├── ProductResponseDto.java
│   └── ProductStockUpdateDto.java
└── model/            <- Representa el concepto de negocio (en esta etapa: sin JPA)
    └── Product.java
```

Regla clave: la logica va en el service, no en el controller. El controller solo
delega, lee parametros y devuelve respuestas HTTP.

---

## Anotaciones Spring esenciales

### A nivel de clase

| Anotacion          | Donde se usa    | Para que sirve                                                        |
|--------------------|-----------------|-----------------------------------------------------------------------|
| @RestController    | Controller      | Indica que la clase atiende requests HTTP y que los metodos devuelven JSON directamente |
| @RequestMapping    | Controller      | Define la ruta base del controller, por ejemplo /api/products         |
| @Service           | Service         | Marca la clase como componente de logica de negocio. Spring la gestiona |

### A nivel de metodo

| Anotacion       | Para que sirve                                             |
|-----------------|------------------------------------------------------------|
| @GetMapping     | Mapea un metodo a una peticion HTTP GET                    |
| @PostMapping    | Mapea un metodo a una peticion HTTP POST                   |
| @PatchMapping   | Mapea un metodo a una peticion HTTP PATCH (actualizacion parcial) |
| @PutMapping     | Mapea un metodo a una peticion HTTP PUT (reemplazo completo) |
| @DeleteMapping  | Mapea un metodo a una peticion HTTP DELETE                 |

### A nivel de parametro

| Anotacion       | Para que sirve                                                        |
|-----------------|-----------------------------------------------------------------------|
| @PathVariable   | Lee un valor de la URL, por ejemplo /api/products/{id}                |
| @RequestBody    | Deserializa el cuerpo del request JSON a un objeto Java               |
| @RequestParam   | Lee query params de la URL, por ejemplo /api/products?name=laptop     |

---

## Inyeccion de dependencias

Spring crea y gestiona los objetos (beans). No crear instancias con `new` en controller o service.

Forma recomendada: inyeccion por constructor.

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }
}
```

Cuando la clase tiene un unico constructor, Spring lo detecta automaticamente y no hace falta
ninguna anotacion extra.

Sin embargo, si la clase tiene mas de un constructor, Spring no sabe cual usar y lanza un error.
En ese caso se debe marcar explicitamente el constructor que debe usar con `@Autowired`:

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    // Spring usara este constructor para inyectar las dependencias
    @Autowired
    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    // Constructor auxiliar (por ejemplo, para tests u otro uso)
    public ProductController() {
        this.productService = null;
    }
}
```

Regla practica: si solo hay un constructor, `@Autowired` es opcional. Si hay mas de uno, es obligatorio
marcarlo para evitar ambiguedad.

---

## ResponseEntity: devolver respuestas HTTP con control

```java
// 200 OK con cuerpo
return ResponseEntity.ok(producto);

// 201 Created con cuerpo
return ResponseEntity.status(HttpStatus.CREATED).body(producto);

// 404 Not Found sin cuerpo
return ResponseEntity.notFound().build();
```

---

## Estructura de endpoints del modulo Product

| Metodo | URL                          | Descripcion                          | Respuesta exitosa |
|--------|------------------------------|--------------------------------------|-------------------|
| GET    | /api/products                | Lista todos los productos            | 200 OK            |
| GET    | /api/products/{id}           | Obtiene un producto por id           | 200 OK            |
| POST   | /api/products                | Crea un nuevo producto               | 201 Created       |
| PATCH  | /api/products/{id}/stock     | Agrega stock al producto existente   | 200 OK            |

---

## Ejemplo de request y response

### POST /api/products
Request body:
```json
{
  "name": "Laptop",
  "description": "Laptop 15 pulgadas",
  "price": 1500.00,
  "stock": 10
}
```

Response body (201 Created):
```json
{
  "id": 1,
  "name": "Laptop",
  "description": "Laptop 15 pulgadas",
  "price": 1500.00,
  "stock": 10
}
```

### PATCH /api/products/1/stock
Request body:
```json
{
  "quantity": 5
}
```

Response body (200 OK):
```json
{
  "id": 1,
  "name": "Laptop",
  "description": "Laptop 15 pulgadas",
  "price": 1500.00,
  "stock": 15
}
```

---

## Lista en memoria: patron basico para esta clase

```java
@Service
public class ProductService {

    private final List<Product> products = new ArrayList<>();
    private Long nextId = 1L;

    public ProductResponseDto create(ProductRequestDto dto) {
        Product product = new Product();
        product.setId(nextId++);
        product.setName(dto.getName());
        // ... mapear el resto de campos
        products.add(product);
        return toResponseDto(product);
    }

    private ProductResponseDto toResponseDto(Product product) {
        ProductResponseDto dto = new ProductResponseDto();
        dto.setId(product.getId());
        dto.setName(product.getName());
        // ... mapear el resto de campos
        return dto;
    }
}
```

---

## Comandos utiles

```bash
# Levantar la aplicacion
.\mvnw spring-boot:run

# Compilar sin ejecutar
.\mvnw clean compile

# Ejecutar tests
.\mvnw test
```

---

## Errores comunes y solucion rapida

| Error                              | Causa probable                                           | Solucion                                               |
|------------------------------------|----------------------------------------------------------|--------------------------------------------------------|
| 404 al llamar un endpoint          | Ruta mal escrita o falta @RequestMapping en el controller | Verificar la URL completa y las anotaciones de mapeo   |
| 400 Bad Request al enviar JSON     | Nombre de campo distinto en el DTO o tipo de dato incorrecto | Comparar los campos del body con los atributos del DTO |
| NullPointerException en service    | El service no fue inyectado correctamente               | Verificar que tenga @Service y que se inyecte por constructor |
| No se persiste el objeto creado    | Se crea una instancia local en lugar de agregar a la lista | Asegurarse de hacer products.add(product) en el service |
| La app no levanta                  | Error de configuracion o dependencia faltante en pom.xml | Leer el stacktrace desde el primer "Caused by"         |
