/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     05.11.2023 12:59:18                          */
/*==============================================================*/


drop index ASSOCIATION_2_FK2;

drop index DELIVERY_PK;

drop table Delivery;

drop index ASSOCIATION_2_FK;

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
   id                   SERIAL               not null,
   Veh_name             VARCHAR(254)         not null,
   name                 VARCHAR(254)         null, 
   current_step         INT4                 not null DEFAULT 1,
   constraint PK_DELIVERY primary key (id)
);

/*==============================================================*/
/* Index: DELIVERY_PK                                           */
/*==============================================================*/
create unique index DELIVERY_PK on Delivery (
id
);

/*==============================================================*/
/* Index: ASSOCIATION_2_FK2                                     */
/*==============================================================*/
create  index ASSOCIATION_2_FK2 on Delivery (
name
);

/*==============================================================*/
/* Table: Driver                                                */
/*==============================================================*/
create table Driver (
   name                 VARCHAR(254)         not null,
   id                   INT4                 null,
   Veh_name             VARCHAR(254)         not null,
   password             VARCHAR(254)         not null,
   constraint PK_DRIVER primary key (name)
);

/*==============================================================*/
/* Index: DRIVER_PK                                             */
/*==============================================================*/
create unique index DRIVER_PK on Driver (
name
);

/*==============================================================*/
/* Index: ASSOCIATION_1_FK                                      */
/*==============================================================*/
create  index ASSOCIATION_1_FK on Driver (
Veh_name
);

/*==============================================================*/
/* Index: ASSOCIATION_2_FK                                      */
/*==============================================================*/
create  index ASSOCIATION_2_FK on Driver (
id
);

/*==============================================================*/
/* Table: Event                                                 */
/*==============================================================*/
create table Event (
   Del_id               INT4                 not null,
   location             VARCHAR(254)         not null,
   step                 INT4                 not null,
   constraint PK_EVENT primary key (Del_id, step)
);

/*==============================================================*/
/* Index: EVENT_PK                                              */
/*==============================================================*/
create unique index EVENT_PK on Event (
Del_id,
step
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
   name                 VARCHAR(254)         not null,
   constraint PK_VEHICLE primary key (name)
);

/*==============================================================*/
/* Index: VEHICLE_PK                                            */
/*==============================================================*/
create unique index VEHICLE_PK on Vehicle (
name
);

/*==============================================================*/
/* Table: Outstanding Updates                                   */
/*==============================================================*/
create table OutstandingUpdates (
   id                   INT4                 not null,
   current_step         INT4                 not null,
   constraint PK_OUTSTANDING_UPDATE primary key (id)
);

alter table Delivery
   add constraint FK_DELIVERY_ASSOCIATI_DRIVER foreign key (name)
      references Driver (name)
      on delete restrict on update restrict;

alter table Delivery
   add constraint FK_DELIVERY_ASSOCIATI_VEHICLE foreign key (Veh_name)
      references Vehicle (name)
      on delete restrict on update restrict;

alter table Driver
   add constraint FK_DRIVER_ASSOCIATI_VEHICLE foreign key (Veh_name)
      references Vehicle (name)
      on delete restrict on update restrict;

alter table Driver
   add constraint FK_DRIVER_ASSOCIATI_DELIVERY foreign key (id)
      references Delivery (id)
      on delete set null on update restrict;

alter table Event
   add constraint FK_EVENT_ASSOCIATI_DELIVERY foreign key (Del_id)
      references Delivery (id)
      on delete cascade on update restrict;

