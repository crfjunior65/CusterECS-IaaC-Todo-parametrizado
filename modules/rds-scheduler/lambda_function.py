import boto3
import json
import logging
import os

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Inicia ou para instância RDS baseado na ação do evento.
    Horários: 08:00 START | 18:00 STOP (Brasília)
    """
    db_instance_identifier = os.environ.get('DB_INSTANCE_IDENTIFIER')
    action = event.get('action')

    logger.info(f"RDS Scheduler executado - Action: {action}, Instance: {db_instance_identifier}")
    logger.info(f"Event completo: {json.dumps(event)}")

    # Validações
    if not db_instance_identifier:
        error_msg = 'DB_INSTANCE_IDENTIFIER não configurado'
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

    rds_client = boto3.client('rds')

    try:
        # Verificar instância RDS
        response = rds_client.describe_db_instances(DBInstanceIdentifier=db_instance_identifier)
        db_instance = response['DBInstances'][0]
        current_status = db_instance['DBInstanceStatus']
        engine = db_instance['Engine']

        logger.info(f"RDS encontrado - Engine: {engine}, Status: {current_status}")

        # Processar START
        if action == 'start':
            if current_status == 'available':
                message = f'RDS {db_instance_identifier} já está rodando'
                logger.info(message)
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': db_instance_identifier,
                        'status': current_status,
                        'action': 'start',
                        'result': 'already_running'
                    })
                }
            elif current_status == 'stopped':
                logger.info(f"Iniciando RDS: {db_instance_identifier}")
                rds_client.start_db_instance(DBInstanceIdentifier=db_instance_identifier)
                message = f'RDS {db_instance_identifier} iniciado com sucesso'
                logger.info(message)

                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': db_instance_identifier,
                        'previous_status': current_status,
                        'action': 'start',
                        'result': 'initiated'
                    })
                }
            else:
                message = f'Não é possível iniciar RDS. Status atual: {current_status}'
                logger.warning(message)
                return {
                    'statusCode': 400,
                    'body': json.dumps({
                        'error': message,
                        'instance': db_instance_identifier,
                        'status': current_status
                    })
                }

        # Processar STOP
        elif action == 'stop':
            if current_status == 'stopped':
                message = f'RDS {db_instance_identifier} já está parado'
                logger.info(message)
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': db_instance_identifier,
                        'status': current_status,
                        'action': 'stop',
                        'result': 'already_stopped'
                    })
                }
            elif current_status == 'available':
                logger.info(f"Parando RDS: {db_instance_identifier}")
                rds_client.stop_db_instance(DBInstanceIdentifier=db_instance_identifier)
                message = f'RDS {db_instance_identifier} parado com sucesso'
                logger.info(message)

                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': message,
                        'instance': db_instance_identifier,
                        'previous_status': current_status,
                        'action': 'stop',
                        'result': 'initiated'
                    })
                }
            else:
                message = f'Não é possível parar RDS. Status atual: {current_status}'
                logger.warning(message)
                return {
                    'statusCode': 400,
                    'body': json.dumps({
                        'error': message,
                        'instance': db_instance_identifier,
                        'status': current_status
                    })
                }

    except rds_client.exceptions.DBInstanceNotFoundFault:
        error_msg = f'RDS {db_instance_identifier} não encontrado'
        logger.error(error_msg)
        return {
            'statusCode': 404,
            'body': json.dumps({'error': error_msg})
        }
    except Exception as e:
        error_msg = f'Erro inesperado: {str(e)}'
        logger.error(error_msg, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': error_msg,
                'instance': db_instance_identifier,
                'action': action
            })
        }
