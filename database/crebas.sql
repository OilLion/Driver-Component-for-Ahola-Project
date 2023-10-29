/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     29.10.2023 12:16:58                          */
/*==============================================================*/


drop index ASSOCIATION_2_FK;

drop index DELIVERY_PK;

drop table Delivery;

drop index ASSOCIATION_1_FK;

drop index DRIVER_PK;

drop table Driver;

drop index ASSOCIATION_3_FK;

drop index EVENT_PK;

drop table Event;

drop index VEHICLE_PK;

drop table Vehicle;

/*==============================================================*/
/* Table: Delivery                                              */
/*==============================================================*/
create table Delivery (
   id                   INT4                 not null,
   Dri_id               INT4                 not null,
   constraint PK_DELIVERY primary key (id)
);

/*==============================================================*/
/* Index: DELIVERY_PK                                           */
/*==============================================================*/
create unique index DELIVERY_PK on Delivery (
id
);

/*==============================================================*/
/* Index: ASSOCIATION_2_FK                                      */
/*==============================================================*/
create  index ASSOCIATION_2_FK on Delivery (
Dri_id
);

/*==============================================================*/
/* Table: Driver                                                */
/*==============================================================*/
create table Driver (
   id                   INT4                 not null,
   Veh_id               INT4                 not null,
   name                 VARCHAR(254)         null,
   password             VARCHAR(254)         null,
   available            BOOL                 null,
   location             VARCHAR(254)         null,
   constraint PK_DRIVER primary key (id)
);

/*==============================================================*/
/* Index: DRIVER_PK                                             */
/*==============================================================*/
create unique index DRIVER_PK on Driver (
id
);

/*==============================================================*/
/* Index: ASSOCIATION_1_FK                                      */
/*==============================================================*/
create  index ASSOCIATION_1_FK on Driver (
Veh_id
);

/*==============================================================*/
/* Table: Event                                                 */
/*==============================================================*/
create table Event (
   Del_id               INT4                 not null,
   id                   INT4                 not null,
   location             VARCHAR(254)         null,
   constraint PK_EVENT primary key (Del_id, id)
);

/*==============================================================*/
/* Index: EVENT_PK                                              */
/*==============================================================*/
create unique index EVENT_PK on Event (
Del_id,
id
);

/*==============================================================*/
/* Index: ASSOCIATION_3_FK                                      */
/*==============================================================*/
create  index ASSOCIATION_3_FK on Event (
Del_id
);

/*==============================================================*/
/* Table: Vehicle                                               */
/*==============================================================*/
create table Vehicle (
   id                   INT4                 not null,
   name                 VARCHAR(254)         null,
   constraint PK_VEHICLE primary key (id)
);

/*==============================================================*/
/* Index: VEHICLE_PK                                            */
/*==============================================================*/
create unique index VEHICLE_PK on Vehicle (
id
);

alter table Delivery
   add constraint FK_DELIVERY_ASSOCIATI_DRIVER foreign key (Dri_id)
      references Driver (id)
      on delete restrict on update restrict;

alter table Driver
   add constraint FK_DRIVER_ASSOCIATI_VEHICLE foreign key (Veh_id)
      references Vehicle (id)
      on delete restrict on update restrict;

alter table Event
   add constraint FK_EVENT_ASSOCIATI_DELIVERY foreign key (Del_id)
      references Delivery (id)
      on delete restrict on update restrict;

