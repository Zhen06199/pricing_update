from kubernetes import client, config
from kubernetes.client.rest import ApiException
import os

def parse_cpu(cpu_str):
    if cpu_str.endswith('n'):  # 纳核
        return float(cpu_str[:-1]) * 1e-9
    elif cpu_str.endswith('u'):  # 微核
        return float(cpu_str[:-1]) * 1e-6
    elif cpu_str.endswith('m'):  # 毫核
        return float(cpu_str[:-1]) / 1000
    else:
        return float(cpu_str)

def main():
    # 加载集群内配置
    config.load_incluster_config()

    node_name = os.getenv('NODE_NAME')
    if not node_name:
        raise Exception("环境变量 NODE_NAME 未设置")

    core_v1 = client.CoreV1Api()
    custom_api = client.CustomObjectsApi()

    # 获取节点容量
    node = core_v1.read_node(node_name)
    cpu_capacity_str = node.status.capacity['cpu']
    cpu_capacity = parse_cpu(cpu_capacity_str)

    # 获取节点使用情况（需要 metrics-server）
    try:
        metrics = custom_api.get_cluster_custom_object(
            group="metrics.k8s.io",
            version="v1beta1",
            plural="nodes",
            name=node_name
        )
        cpu_usage_str = metrics['usage']['cpu']
        cpu_usage = parse_cpu(cpu_usage_str)
    except ApiException as e:
        print(f"获取 metrics 失败: {e}")
        cpu_usage = 0.0

    cpu_remaining = cpu_capacity - cpu_usage

    print(f"节点 {node_name} CPU 容量: {cpu_capacity} cores")
    print(f"节点 {node_name} CPU 使用: {cpu_usage} cores")
    print(f"节点 {node_name} CPU 剩余: {cpu_remaining} cores")

if __name__ == "__main__":
    main()
