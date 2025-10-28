import boto3
import json
import logging
import os

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Inicia ou para instância EC2 Bastion Host baseado na ação do evento.
    Horários: 08:00 START | 18:00 STOP (Brasília)
    """
    instance_id = os.environ.get('BASTION_INSTANCE_ID')
    action = event.get('action')

    logger.info(f"Bastion Scheduler executado - Action: {action}, Instance: {instance_id}")
    logger.info(f"Event completo: {json.dumps(event)}")

    # Validações
    if not instance_id:
        error_msg = 'BASTION_INSTANCE_ID não configurado'
        logger.error(error_msg)
        return {
            'statusCode': 400,
            'body': json.dumps({'error': error_msg})
        }

    if action not in ['start', 'stop']:
        error_msg = f"Ação inválida: {action}. Use 'start' ou 'stop'"
        logger.error(error_msg)
        return {
            'statusCode': 400,
            'body': json.dumps({'error': error_msg})
        }

    ec2_client = boto3.client('ec2')

    try:
        # Verificar instância EC2
        response = ec2_client.describe_instances(InstanceIds=[instance_id])

        if not response['Reservations']:
            error_msg = f'Instância EC2 {instance_id} não encontrada'
            logger.error(error_msg)
            return {
                'statusCode': 404,
                'body': json.dumps({'error': error_msg})
            }

        instance = response['Reservations'][0]['Instances'][0]
        current_state = instance['State']['Name']
        instance_type = instance['InstanceType']

        logger.info(f"Bastion encontrado - Type: {instance_type}, State: {current_state}")

        # Processar START
        if action == 'start':
            if current_state == 'running':
                message = f'Bastion {instance_id} já está rodando'
                logger.info(message)
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': instance_id,
                        'state': current_state,
                        'action': 'start',
                        'result': 'already_running'
                    })
                }
            elif current_state == 'stopped':
                logger.info(f"Iniciando Bastion: {instance_id}")
                ec2_client.start_instances(InstanceIds=[instance_id])
                message = f'Bastion {instance_id} iniciado com sucesso'
                logger.info(message)

                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': instance_id,
                        'previous_state': current_state,
                        'action': 'start',
                        'result': 'initiated'
                    })
                }
            else:
                message = f'Não é possível iniciar Bastion. Estado atual: {current_state}'
                logger.warning(message)
                return {
                    'statusCode': 400,
                    'body': json.dumps({
                        'error': message,
                        'instance': instance_id,
                        'state': current_state
                    })
                }

        # Processar STOP
        elif action == 'stop':
            if current_state == 'stopped':
                message = f'Bastion {instance_id} já está parado'
                logger.info(message)
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': instance_id,
                        'state': current_state,
                        'action': 'stop',
                        'result': 'already_stopped'
                    })
                }
            elif current_state == 'running':
                logger.info(f"Parando Bastion: {instance_id}")
                ec2_client.stop_instances(InstanceIds=[instance_id])
                message = f'Bastion {instance_id} parado com sucesso'
                logger.info(message)

                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': instance_id,
                        'previous_state': current_state,
                        'action': 'stop',
                        'result': 'initiated'
                    })
                }
            else:
                message = f'Não é possível parar Bastion. Estado atual: {current_state}'
                logger.warning(message)
                return {
                    'statusCode': 400,
                    'body': json.dumps({
                        'error': message,
                        'instance': instance_id,
                        'state': current_state
                    })
                }

    except Exception as e:
        error_msg = f'Erro inesperado: {str(e)}'
        logger.error(error_msg, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': error_msg,
                'instance': instance_id,
                'action': action
            })
        }
