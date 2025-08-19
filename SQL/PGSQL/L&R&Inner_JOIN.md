## 1. INNER JOIN
Example of table 1 **transcations**:

   <img width="446" height="231" alt="image" src="https://github.com/user-attachments/assets/533c541d-49a2-46b9-8d49-2df54b765f32" />

Example of table 2 **customers**:

<img width="444" height="192" alt="image" src="https://github.com/user-attachments/assets/a281d387-d298-4e11-9b2e-c128c432cea7" />

```SQL
SELECT *
FROM transactions INNER JOIN customers
ON transcations.customer_id=customers.customer_id
```
(可以改变select去筛选想看到的值)

<img width="896" height="185" alt="image" src="https://github.com/user-attachments/assets/476fa977-150c-46df-b3de-5195643aea24" />

## 2. LEFT JOIN 
```SQL
SELECT *
FROM transactions LEFT JOIN customers
ON transcations.customer_id=customers.customer_id
```

<img width="857" height="221" alt="image" src="https://github.com/user-attachments/assets/33936a69-bac6-4d3e-a898-bb09077127dd" />

## 3. RIGHT JOIN
```SQL
SELECT *
FROM transactions RIGHT JOIN customers
ON transcations.customer_id=customers.customer_id
```

<img width="872" height="231" alt="image" src="https://github.com/user-attachments/assets/bdaf7e03-04cc-4b08-b6f4-c49da5ff40c7" />
