* Encoding: UTF-8.
*Data cleaning examples of dropping, renaming, recoding, and computing variables
    *Dataset = Qualtrics export of Jongerenvragenlijst meetronde #1_October 4 2023
    

*DROPPING VARIABLES

DELETE VARIABLES StartDate EndDate Status IPAddress Progress Finished RecipientLastName RecipientFirstName RecipientEmail ExternalReference LocationLatitude LocationLongitude DistributionChannel UserLanguage.
EXECUTE.

*RENAMING VARIABLES
    *Background variables
    
RENAME VARIABLES (A1 A1_4_TEXT A2a A2b A3 A3_4_TEXT A4a A5a A5a_8_TEXT A4b A5b A4c = Gender Gender_x Geboortemaand Geboortejaar Onderwijstype Onderwijstype_x POgroep VOniveau VOniveau_x VOjaar TOniveau TOjaar).
EXECUTE.

VARIABLE LABELS Gender (Hoe identificeer jij je?).
EXECUTE.

    *Instrument Veranderingen Na Scheiding = VnS

RENAME VARIABLES (B2_B4_1 TO B5_B12_8 = VnS_1 TO VnS_11).
EXECUTE.

    *Instrument Behaviour and Feelings Scale = BFS
 
RENAME VARIABLES (R1_R6_1 TO R7_R12_6 = BFS_1 TO BFS_12).
EXECUTE.

*RECODING VARIABLES

RECODE Geboortejaar (4=2004) (5=2005) (6=2006) (7=2007) (8=2008) (9=2009) (10=2010) (11=2011) 
    (12=2012) (13=2013) (14=2014) (15=2015) (16=2016).
EXECUTE.

VALUE LABELS Geboortejaar (null).
ADD VALUE LABELS Geboortejaar 2004'2004'  2005'2005' 2006'2006' 2007'2007' 2008'2008' 2009'2009' 2010'2010' 2011'2011' 2012'2012' 2013'2013' 2014'2014' 2015'2015' 2016'2016'.

RECODE BFS_1 TO BFS_12 (0=1) (1=2) (2=3) (3=4) (4=5).
EXECUTE.
VALUE LABELS BFS_1 to BFS_12 (null).
EXECUTE.
ADD VALUE LABELS BFS_1 to BFS_12  1'Niet' 2'Zelden' 3'Soms' 4'Vaak' 5'Altijd'.
EXECUTE.

*COMPUTING VARIABLES
    *AGE IN TWO STEPS
        *STEP 1. COMPUTE GEBOORTEDATUM

COMPUTE Geboortedatum=DATE.MOYR(Geboortemaand,Geboortejaar).
EXECUTE.

        *STEP 2. COMPUTE AGE BASED ON GEBOORTEDATUM & RECORDED DATE

COMPUTE  Leeftijd=(RecordedDate - Geboortedatum) / (365.25 * time.days(1)).
VARIABLE LABELS  Leeftijd "Retain fractional parts".
VARIABLE LEVEL  Leeftijd (SCALE).
FORMATS  Leeftijd (F8.2).
VARIABLE WIDTH  Leeftijd(8).
EXECUTE.

    *SIMPLE SUMSCORE NUMBER OF CHANGES FOLLOWING PARENTAL DIVORCE
 
COMPUTE VnS_Sum=SUM(VnS_1,VnS_2,VnS_3,VnS_4,VnS_5,VnS_6,VnS_7,VnS_8,VnS_9,VnS_10,VnS_11).
EXECUTE.

    *SIMPLE MEAN SCORE BASED ON BFS ITEMS
    
COMPUTE BFS_Mean=MEAN(BFS_1,BFS_2,BFS_3,BFS_4,BFS_5,BFS_6,BFS_7,BFS_8,BFS_9,BFS_10,BFS_11,BFS_12).
EXECUTE.
