# Clase 02 - Cheatsheet

## Objetivo del cheatsheet
- Recordar el patron de validacion para DTOs en Spring Boot.
- Usar el ejemplo de `Product` como referencia de clase, pero aplicar el mismo criterio a un DTO nuevo en la tarea.

## 1. Dependencia necesaria

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

## 2. Ejemplo visto en clase: validacion de Product

```java
public class ProductRequestDto {

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 3, message = "El nombre debe tener al menos 3 caracteres")
    private String name;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser mayor a cero")
    private BigDecimal price;

    @NotNull(message = "El stock es obligatorio")
    @PositiveOrZero(message = "El stock no puede ser negativo")
    private Integer stock;
}
```

## 3. Activar validacion en el controller

```java
@PostMapping
public ResponseEntity<ProductResponseDto> create(@Valid @RequestBody ProductRequestDto request) {
    return ResponseEntity.ok(service.create(request));
}
```

## 4. Como aplicarlo a un DTO nuevo

```java
public class CustomerRequestDto {

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, message = "El nombre debe tener al menos 2 caracteres")
    private String firstName;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "Debe ingresar un email valido")
    private String email;
}
```

## 5. Reglas utiles que suelen aparecer

- `@NotBlank`: texto obligatorio y sin espacios vacios.
- `@NotNull`: campo obligatorio.
- `@Size(min = ..., max = ...)`: longitud minima/maxima.
- `@Positive`: numero mayor a cero.
- `@PositiveOrZero`: numero mayor o igual a cero.
- `@Email`: formato valido de email.
- `@Pattern`: reglas personalizadas con expresiones regulares.

## 6. Documentacion oficial

- Jakarta Bean Validation API: https://jakarta.ee/specifications/bean-validation/3.0/apidocs/jakarta/validation/constraints/package-summary
- Esta referencia oficial muestra todas las constraints estandar, su semantica y sus nombres exactos.

## 7. Errores comunes

- Olvidar agregar la dependencia `spring-boot-starter-validation`.
- No poner `@Valid` en `@RequestBody`.
- Validar en el modelo `Product` en lugar de en el DTO.
- Repetir exactamente la validacion de Product sin aplicar el criterio a un DTO nuevo.

## 8. Recomendacion didactica

- El ejemplo de `Product` es una guia para entender el patron.
- La tarea debe decidir reglas propias para un nuevo DTO del proyecto.
- La idea es reutilizar la herramienta, no copiar la solucion exacta del caso ya visto en clase.
- Cuando tengan dudas sobre una anotacion, consultar primero la documentacion oficial de Jakarta Validation.
