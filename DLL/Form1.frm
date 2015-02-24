VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "DLL_TEST"
   ClientHeight    =   4035
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   6195
   LinkTopic       =   "Form1"
   ScaleHeight     =   4035
   ScaleWidth      =   6195
   StartUpPosition =   3  '系統預設值
   Begin VB.TextBox Text2 
      Height          =   375
      Left            =   720
      TabIndex        =   6
      Text            =   "127.0.0.1"
      Top             =   120
      Width           =   3255
   End
   Begin VB.TextBox Text1 
      Height          =   2775
      Left            =   2040
      MultiLine       =   -1  'True
      ScrollBars      =   2  '垂直捲軸
      TabIndex        =   4
      Top             =   600
      Width           =   3255
   End
   Begin VB.CommandButton Command4 
      Caption         =   "GetSIMState"
      Height          =   615
      Left            =   240
      TabIndex        =   3
      Top             =   2760
      Width           =   1575
   End
   Begin VB.CommandButton Command3 
      Caption         =   "GetBARState"
      Height          =   615
      Left            =   240
      TabIndex        =   2
      Top             =   2040
      Width           =   1575
   End
   Begin VB.CommandButton Command2 
      Caption         =   "ResetSIM"
      Height          =   615
      Left            =   240
      TabIndex        =   1
      Top             =   1320
      Width           =   1575
   End
   Begin VB.CommandButton Command1 
      Caption         =   "ResetBAR"
      Height          =   615
      Left            =   240
      TabIndex        =   0
      Top             =   600
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "IP"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   240
      Width           =   375
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function FEMET_ResetBAR Lib "FEMET_Service.dll" (ByVal IP As String) As Boolean
Private Declare Function FEMET_ResetSIM Lib "FEMET_Service.dll" (ByVal IP As String) As Boolean
Private Declare Function FEMET_GetBARState Lib "FEMET_Service.dll" (ByVal IP As String) As String
Private Declare Function FEMET_GetSIMState Lib "FEMET_Service.dll" (ByVal IP As String) As String

Private Sub Command1_Click()
    Text1.Text = FEMET_ResetBAR(Text2.Text)
End Sub

Private Sub Command2_Click()
    Text1.Text = FEMET_ResetBAR(Text2.Text)
End Sub

Private Sub Command3_Click()
    Text1.Text = FEMET_GetBARState(Text2.Text)
End Sub

Private Sub Command4_Click()
    Text1.Text = FEMET_GetSIMState(Text2.Text)
End Sub
