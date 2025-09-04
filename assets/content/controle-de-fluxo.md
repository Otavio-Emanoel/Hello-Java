# Controle de Fluxo

## if / else
```java
int x = 10;
if (x > 5) {
  System.out.println("maior que 5");
} else {
  System.out.println("menor ou igual a 5");
}
```

## switch
```java
int dia = 3;
switch (dia) {
  case 1 -> System.out.println("Segunda");
  case 2 -> System.out.println("Terça");
  case 3 -> System.out.println("Quarta");
  default -> System.out.println("Outro dia");
}
```

## loops
```java
for (int i = 0; i < 3; i++) {
  System.out.println(i);
}

int j = 0;
while (j < 3) {
  System.out.println(j);
  j++;
}

do {
  System.out.println("executa ao menos uma vez");
} while (false);
```
