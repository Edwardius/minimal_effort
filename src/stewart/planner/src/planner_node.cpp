#include <chrono>
#include <memory>

#include "planner_node.hpp"

PlannerNode::PlannerNode() : Node("planner")
{
}

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<PlannerNode>());
  rclcpp::shutdown();
  return 0;
}
