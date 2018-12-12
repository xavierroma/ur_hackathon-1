package main

const (
	RobotModeData = iota
	JointData = iota
	ToolData = iota
	MasterboardData = iota
	CartesianData = iota
	KinematicsData = iota
	ConfigurationData = iota
	ForceModeData = iota
	AdditionalData = iota
	CalibrationData = iota
	SafetyData = iota
	ToolCommData = iota
)
/*
value 0 ("Robot Mode Data")
value 1 ("Joint Data")
value 2 ("Tool Data")
value 3 ("Masterboard Data")
value 4 ("Cartesian Info")
value 5 ("Kinematics Info")
value 6 ("Configuration Data")
value 7 ("Force Mode Data")
value 8 ("Additional Info")
value 9 ("Calibration Data")
value 10 ("Safety Data")
value 11 ("Tool Comm Info")
*/

type JointDataStruct struct {

	IndJoint  [6]IndividualJoint `json:"ind_joint"`

}

type IndividualJoint struct {
	ActJointPos     uint64 `json:"act_joint_pos"`
	TarJointPos	uint64 `json:"tar_joint_pos"`
	ActJointSpeed uint64 `json:"act_joint_speed"`
	ActJointCurrent uint32 `json:"act_joint_current"`
	JointTemp	uint64 `json:"joint_temp"`
	a	uint32 `json:"joint_temp"`
	b	uint64 `json:"joint_temp"`
	c	uint8 `json:"joint_temp"`
}
