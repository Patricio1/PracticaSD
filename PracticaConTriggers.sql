
create table ALMACENES (
   N_ALMACEN numeric(2) not null,
   DESC_ALMACEN varchar(25) null,
   DIREC_ALMACEN varchar(30) null,
   constraint llave_ALMACENES primary key nonclustered (N_ALMACEN)
)
go

create table EMPRESAS (
   CIF varchar(9) not null,
   NOMBRE varchar(50) null,
   TELEFONO char(9) null,
   LOCALIDAD varchar(50) null,
   PROVINCIA varchar(30)null,
   DIREC_EMPRESA varchar(50) null,
   constraint llave_EMPRESAS primary key nonclustered (CIF)
)
go


create table EXISTENCIAS (
   N_ALMACEN numeric(2)           null,
   TIPO                 varchar(2)           null,
   MODELO               numeric(2)           null,
   CANTIDAD             numeric(9)           null
)
go


create index ALMA_EXIS_FORANEAK on EXISTENCIAS (
N_ALMACEN ASC
)
go


create index PIEZA_EXIST_FORANEAK on EXISTENCIAS (
TIPO ASC,
MODELO ASC
)
go

create table PIEZAS (
   TIPO                 varchar(2)           not null,
   MODELO               numeric(2)           not null,
   PRECIO_VENTA         numeric(11,4)        null,
   constraint llave_PIEZAS primary key nonclustered (TIPO, MODELO)
)
go


create index TIPOS_PIEZAS_FORANEAK on PIEZAS (
TIPO ASC
)
go

create table SUMINISTROS (
   CIF                  varchar(9)           null,
   TIPO                 varchar(2)           null,
   MODELO               numeric(2)           null,
   PRECIO_COMPRA        numeric(11,4)        null
)
go


create index PIEZAS_SUMI_FORANEAK on SUMINISTROS (
TIPO ASC,
MODELO ASC
)
go

create index EMPRE_SUMI_FORANEAK on SUMINISTROS (
CIF ASC
)
go

create table TIPOS (
   TIPO                 varchar(2)           not null,
   DESC_TIPO            varchar(20)          null,
   constraint llave_TIPOS primary key nonclustered (TIPO)
)
go


alter table EXISTENCIAS
   add constraint rel_exis_almac foreign key (N_ALMACEN)
      references ALMACENES (N_ALMACEN)
         on update cascade on delete cascade
go

alter table EXISTENCIAS
   add constraint rel_exist_piezas foreign key (TIPO, MODELO)
      references PIEZAS (TIPO, MODELO)
         on update cascade on delete cascade
go

alter table PIEZAS
   add constraint rel_piezas_tipos foreign key (TIPO)
      references TIPOS (TIPO)
         on update cascade on delete cascade
go

alter table SUMINISTROS
   add constraint rel_sumnis_empresas foreign key (CIF)
      references EMPRESAS (CIF)
         on update cascade on delete cascade
go

alter table SUMINISTROS
   add constraint rel_sumi_piezas foreign key (TIPO, MODELO)
      references PIEZAS (TIPO, MODELO)
         on update cascade on delete cascade
go


 
/*AUITORIA*/

/*CREACION DE TABLA PARA AUDITAR SUMINISTROS*/
CREATE TABLE SUMINISTROS_AUDIT(
TIPO VARCHAR(2),
MODELO NUMERIC(2),
CIF VARCHAR(9), 
PRECIO_VIEJO NUMERIC(11,4),
PRECIO_NUEVO NUMERIC(11,4),
FECHA DATE
);

/*CREACION DE PROCEDIMIENTO PARA INSERTAR DATOS EN TABLA AUDITAR_SUMINISTROS*/
CREATE PROCEDURE INSERTAR_SUMINISTROS_AUDIT
@TIPO VARCHAR(2),
@MODELO NUMERIC(2),
@CIF VARCHAR(9),
@NUEVO_PRECIO_COMPRA NUMERIC(11,4),
@VIEJO_PRECIO_COMPRA NUMERIC(11,4)
 AS
 DECLARE @FECHA DATE
 SELECT @FECHA =( SELECT GETDATE()) 
 INSERT INTO SUMINISTROS_AUDIT(TIPO,MODELO,CIF,PRECIO_VIEJO,PRECIO_NUEVO,FECHA)
 VALUES(@TIPO,@MODELO,@CIF,@VIEJO_PRECIO_COMPRA,@NUEVO_PRECIO_COMPRA,@FECHA);

/*CREACION DE TRIGGER PARA AUDITAR*/

CREATE TRIGGER AUDITORIA 
ON SUMINISTROS
FOR UPDATE 
AS
BEGIN
DECLARE @TIP_PIE VARCHAR(2)
DECLARE @MOD_PIE NUMERIC(2)
DECLARE @CIF_SUM VARCHAR(9)
DECLARE @PRE_NUE NUMERIC(11,4)
DECLARE @PRE_VIE NUMERIC(11,4)
IF UPDATE(PRECIO_COMPRA)
BEGIN
SELECT @TIP_PIE  =  (SELECT TIPO FROM INSERTED),
 @MOD_PIE = (SELECT MODELO FROM INSERTED),
 @CIF_SUM = (SELECT CIF FROM INSERTED),
 @PRE_NUE = (SELECT PRECIO_COMPRA FROM DELETED),
 @PRE_VIE = (SELECT PRECIO_COMPRA FROM INSERTED); 
 EXEC INSERTAR_SUMINISTROS_AUDIT @TIP_PIE,@MOD_PIE,@CIF_SUM,@PRE_VIE,@PRE_NUE;
 END;
END;

/*PRUEBA CON DATOS*/
INSERT INTO EMPRESAS
VALUES('AB0001','EMPRESA1','032748878','AMBATO','TUNGURAHUA','AV 12 NOVIEMBRE');

INSERT INTO TIPOS VALUES('AB','MEDIANO');

INSERT INTO PIEZAS VALUES('AB',1,5.50);

INSERT INTO SUMINISTROS VALUES
('AB0001','AB',1,5);

INSERT INTO SUMINISTROS VALUES
('AB0001','AB',2,3.90);

/*PRUEBA DEL TRIGGER AL ACTUALIZAR CAMPO PRECIO_COMPRA EN LA TABLA SUMINISTROS*/
UPDATE SUMINISTROS SET PRECIO_COMPRA= 4.50 WHERE MODELO=1;

UPDATE SUMINISTROS SET PRECIO_COMPRA = 3.80 WHERE MODELO=2;


